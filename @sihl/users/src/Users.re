module User = Service.User;
module Seeds = Seeds;
module App = App;
module AdminUi = {
  module NavigationLayout = AdminUi.NavigationLayout;
  module Page = AdminUi.Page;
  let render = AdminUi.HtmlTemplate.render;
  let pages = AdminUi.State.pages^;
};
