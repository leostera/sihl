module type SESSION_SERVICE = sig
  val set : key:string -> value:string -> Opium_kernel.Request.t -> unit Lwt.t

  val remove : key:string -> Opium_kernel.Request.t -> unit Lwt.t

  val get : string -> Opium_kernel.Request.t -> string option Lwt.t
end

let registry_key : (module SESSION_SERVICE) Core.Container.Key.t =
  Core.Container.Key.create "session.service"

let key = registry_key

let set ~key ~value req =
  match Core.Container.fetch registry_key with
  | Some (module Service : SESSION_SERVICE) -> Service.set ~key ~value req
  | None ->
      let msg =
        "SESSION: Could not find session service, have you installed the \
         session app?"
      in
      Logs.err (fun m -> m "%s" msg);
      failwith msg

let remove ~key req =
  match Core.Container.fetch registry_key with
  | Some (module Service : SESSION_SERVICE) -> Service.remove ~key req
  | None ->
      let msg =
        "SESSION: Could not find session service, have you installed the \
         session app?"
      in
      Logs.err (fun m -> m "%s" msg);
      failwith msg

let get key req =
  match Core.Container.fetch registry_key with
  | Some (module Service : SESSION_SERVICE) -> Service.get key req
  | None ->
      let msg =
        "SESSION: Could not find session service, have you installed the \
         session app?"
      in
      Logs.err (fun m -> m "%s" msg);
      failwith msg
