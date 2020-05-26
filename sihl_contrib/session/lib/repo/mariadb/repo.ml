module Sql = struct
  (* TODO move to some common mariadb namespace *)
  let set_fk_check connection status =
    let module Connection = (val connection : Caqti_lwt.CONNECTION) in
    let request =
      Caqti_request.exec Caqti_type.bool
        {sql|
        SET FOREIGN_KEY_CHECKS = ?;
           |sql}
    in
    Connection.exec request status

  module Session = struct
    module Model = struct
      open Sihl_session.Model.Session

      let t =
        let encode m = Ok (m.key, m.data, m.expire_date) in
        let decode (key, data, expire_date) = Ok { key; data; expire_date } in
        Caqti_type.(custom ~encode ~decode (tup3 string string ptime))
    end

    let get_all connection =
      let module Connection = (val connection : Caqti_lwt.CONNECTION) in
      let request =
        Caqti_request.find Caqti_type.unit Model.t
          {sql|
        SELECT
          session_key,
          session_data,
          expire_date
        FROM sessions_sessions
        |sql}
      in
      Connection.collect_list request

    let get connection =
      let module Connection = (val connection : Caqti_lwt.CONNECTION) in
      let request =
        Caqti_request.find_opt Caqti_type.string Model.t
          {sql|
        SELECT
          session_key,
          session_data,
          expire_date
        FROM sessions_sessions
        WHERE sessions_sessions.key = ?
        |sql}
      in
      Connection.find_opt request

    let upsert connection =
      let module Connection = (val connection : Caqti_lwt.CONNECTION) in
      let request =
        Caqti_request.exec Model.t
          {sql|
        INSERT INTO sessions_sessions (
          session_key,
          session_data,
          expire_date
        ) VALUES (
          ?,
          ?,
          ?
        ) ON DUPLICATE KEY UPDATE
        session_data = VALUES(session_data)
        |sql}
      in
      Connection.exec request

    let delete connection =
      let module Connection = (val connection : Caqti_lwt.CONNECTION) in
      let request =
        Caqti_request.exec Caqti_type.string
          {sql|
      DELETE FROM sessions_sessions
      WHERE sessions_sessions.key = ?
      |sql}
      in
      Connection.exec request

    let clean connection =
      let module Connection = (val connection : Caqti_lwt.CONNECTION) in
      let request =
        Caqti_request.exec Caqti_type.unit
          {sql|
           TRUNCATE sessions_sessions;
          |sql}
      in
      Connection.exec request ()
  end
end

module Migration = struct
  (* TODO move in some mariadb common module *)
  let migrate str connection =
    let module Connection = (val connection : Caqti_lwt.CONNECTION) in
    let request = Caqti_request.exec Caqti_type.unit str in
    Connection.exec request

  let create_sessions_table =
    migrate
      {sql|
CREATE TABLE sessions_sessions (
  id serial,
  session_key VARCHAR(64) NOT NULL,
  session_data VARCHAR(1024) NOT NULL,
  expire_date TIMESTAMP NOT NULL,
  PRIMARY KEY(id),
  CONSTRAINT unique_key UNIQUE(session_key)
);
|sql}

  let migration () =
    ("sessions", [ ("create sessions table", create_sessions_table) ])
end

let get_all connection = Sql.Session.get_all connection ()

let get ~key connection = Sql.Session.get connection key

let insert session connection = Sql.Session.upsert connection session

let update session connection = Sql.Session.upsert connection session

let delete ~key connection = Sql.Session.delete connection key

let migrate = Migration.migration

let clean connection =
  let ( let* ) = Lwt_result.bind in
  let* () = Sql.set_fk_check connection false in
  let* () = Sql.Session.clean connection in
  Sql.set_fk_check connection true
