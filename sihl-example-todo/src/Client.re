module Layout = {
  module LoginRegister = {
    [@react.component]
    let make = () => {
      <div>
        <div className="field is-grouped">
          <div className="control">
            <button
              className="button"
              onClick={event => {
                ReactEvent.Mouse.preventDefault(event);
                ReasonReactRouter.push("/app/login");
              }}>
              {React.string("Login")}
            </button>
          </div>
          <div className="control">
            <button
              className="button"
              onClick={event => {
                ReactEvent.Mouse.preventDefault(event);
                ReasonReactRouter.push("/app/register");
              }}>
              {React.string("Register")}
            </button>
          </div>
        </div>
      </div>;
    };
  };

  module Logout = {
    [@react.component]
    let make = () => {
      <button
        className="button is-danger is-pulled-right"
        onClick={event => {
          let _ = ReactEvent.Mouse.preventDefault(event);
          // TODO logout
          ();
        }}>
        {React.string("Logout")}
      </button>;
    };
  };

  [@react.component]
  let make = (~children, ~isLoggedIn) => {
    <div>
      <section className="hero is-small is-primary is-bold">
        <div className="hero-body">
          <div className="columns">
            <div className="column is-three-quarter">
              <div className="container">
                <h1 className="title">
                  {React.string("Issue Management App")}
                </h1>
                <h2 className="subtitle"> {React.string("Sihl Demo")} </h2>
              </div>
            </div>
            <div className="column is-one-quarter">
              {isLoggedIn ? <Logout /> : <LoginRegister />}
            </div>
          </div>
        </div>
      </section>
      <section
        className="section"
        style={ReactDOMRe.Style.make(~minHeight="40em", ())}>
        children
      </section>
      <footer className="footer">
        <div className="content has-text-centered">
          <p>
            {React.string({js|\u00a9|js})}
            {React.string(" Oxidizing Systems")}
            {React.string(" | ")}
            {React.string("v0.0.1")}
          </p>
        </div>
      </footer>
    </div>;
  };
};

let wrapFormValue = event => {
  let value = ReactEvent.Form.target(event)##value;
  value === "" ? None : Some(value);
};

module Register = {
  module Async = Sihl.Core.Async;
  let register = (~username, ~givenName, ~familyName, ~email, ~password) => {
    let username = username->Belt.Option.getWithDefault("test-user");
    let givenName = givenName->Belt.Option.getWithDefault("Test");
    let familyName = familyName->Belt.Option.getWithDefault("User");
    let email = email->Belt.Option.getWithDefault("test-user@example.com");
    let password = password->Belt.Option.getWithDefault("123");
    let body = {j|
       {
         "email": "$(email)",
         "username": "$(username)",
         "password": "$(password)",
         "givenName": "$(givenName)",
         "familyName": "$(familyName)"
       }
       |j};

    Fetch.fetchWithInit(
      ClientConfig.baseUrl() ++ "/users/register/",
      Fetch.RequestInit.make(
        ~method_=Post,
        ~body=Fetch.BodyInit.make(body),
        (),
      ),
    );
  };

  [@react.component]
  let make = () => {
    let (username, setUsername) = React.useState(() => None);
    let (givenName, setGivenName) = React.useState(() => None);
    let (familyName, setFamilyName) = React.useState(() => None);
    let (email, setEmail) = React.useState(() => None);
    let (password, setPassword) = React.useState(() => None);
    let canSubmit =
      switch (username, givenName, familyName, email, password) {
      | (Some(_), Some(_), Some(_), Some(_), Some(_)) => true
      | _ => false
      };

    <Layout isLoggedIn=false>
      <div className="columns">
        <div className="column is-one-quarter" />
        <div className="column is-two-quarters">
          <h2 className="title is-2"> {React.string("Register")} </h2>
          <div className="field">
            <label className="label"> {React.string("Username")} </label>
            <div className="control">
              <input
                value={username->Belt.Option.getWithDefault("")}
                onChange={event => {
                  let username = wrapFormValue(event);
                  setUsername(_ => username);
                }}
                className="input"
                type_="text"
                required=true
                placeholder=""
              />
            </div>
          </div>
          <div className="field">
            <label className="label"> {React.string("Given name")} </label>
            <div className="control">
              <input
                onChange={event => {
                  let givenName = wrapFormValue(event);
                  setGivenName(_ => givenName);
                }}
                value={givenName->Belt.Option.getWithDefault("")}
                className="input"
                name="givenName"
                type_="text"
                placeholder=""
              />
            </div>
          </div>
          <div className="field">
            <label className="label"> {React.string("Family name")} </label>
            <div className="control">
              <input
                onChange={event => {
                  let familyName = wrapFormValue(event);
                  setFamilyName(_ => familyName);
                }}
                value={familyName->Belt.Option.getWithDefault("")}
                className="input"
                name="familyName"
                type_="text"
                placeholder=""
              />
            </div>
          </div>
          <div className="field">
            <label className="label"> {React.string("Email address")} </label>
            <div className="control">
              <input
                onChange={event => {
                  let email = wrapFormValue(event);
                  setEmail(_ => email);
                }}
                value={email->Belt.Option.getWithDefault("")}
                className="input"
                name="email"
                type_="email"
                placeholder=""
              />
            </div>
          </div>
          <div className="field">
            <label className="label"> {React.string("Password")} </label>
            <div className="control">
              <input
                onChange={event => {
                  let password = wrapFormValue(event);
                  setPassword(_ => password);
                }}
                value={password->Belt.Option.getWithDefault("")}
                className="input"
                name="password"
                type_="password"
                placeholder=""
              />
            </div>
          </div>
          <div className="field is-grouped">
            <div className="control">
              <button
                className="button is-link"
                disabled={!canSubmit}
                onClick={_ => {
                  let _ =
                    register(
                      ~username,
                      ~givenName,
                      ~familyName,
                      ~email,
                      ~password,
                    );
                  ();
                }}>
                {React.string("Register")}
              </button>
            </div>
          </div>
        </div>
        <div className="column is-one-quarter" />
      </div>
    </Layout>;
  };
};

module Login = {
  [@react.component]
  let make = () =>
    <Layout isLoggedIn=false>
      <div className="columns">
        <div className="column is-one-quarter" />
        <div className="column is-two-quarters">
          <h2 className="title is-2"> {React.string("Login")} </h2>
          <div className="field">
            <label className="label"> {React.string("Email address")} </label>
            <div className="control has-icons-left">
              <input
                className="input"
                name="email"
                type_="email"
                placeholder=""
              />
              <span className="icon is-small is-left">
                <i className="fas fa-envelope" />
              </span>
            </div>
          </div>
          <div className="field">
            <label className="label"> {React.string("Password")} </label>
            <div className="control has-icons-left">
              <input
                className="input"
                name="password"
                type_="password"
                placeholder=""
              />
              <span className="icon is-small is-left">
                <i className="fas fa-lock" />
              </span>
            </div>
          </div>
          <div className="field is-grouped">
            <div className="control">
              <button className="button is-link" value="Login">
                {React.string("Login")}
              </button>
            </div>
          </div>
        </div>
        <div className="column is-one-quarter" />
      </div>
    </Layout>;
};

module Main = {
  [@react.component]
  let make = () => {
    let url = ReasonReactRouter.useUrl();
    switch (url.path) {
    | ["app", "login"] => <Login />
    | ["app", "register"] => <Register />
    | _ => <Login />
    };
  };
};

ReactDOMRe.renderToElementWithId(<Main />, "app");
