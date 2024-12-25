module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/assets/stylesheets/**/*.css",
    "./app/javascript/**/*.js",
  ],
  theme: {
    extend: {
      colors: {
        primary: "#25282b",
        primarybg: "#F9FAF5",
        darkbg: "#caccc6",
        lightbg: "#f6f6ef",
        accent: "#d3f26a",
      },
    },
  },
};
