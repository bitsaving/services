part of directcode.services.ui;

@Route("/docs", responseType: "text/html")
@Markdown()
docsHome() => docs("home");

@Route("/docs/:page", responseType: "text/html")
@Markdown()
docs(String page) {
  var file = new File("docs/${page}.md");
  
  if (!file.existsSync()) {
    throw new ErrorResponse(404, "Page Not Found");
  }
  
  return file;
}