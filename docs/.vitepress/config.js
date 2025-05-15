export default {
  title: "Pears",
  description: "A lightweight, fast, and reliable package manager and system configuration tool",
  themeConfig: {
    logo: "/logo.png",
    nav: [
      { text: "Home", link: "/" },
      { text: "Guide", link: "/guide/" },
      { text: "Reference", link: "/reference/" },
      { text: "GitHub", link: "https://github.com/dunnoconz/pears" }
    ],
    sidebar: {
      "/guide/": [
        {
          text: "Getting Started",
          items: [
            { text: "Introduction", link: "/guide/" },
            { text: "Installation", link: "/guide/installation" },
            { text: "Configuration", link: "/guide/configuration" },
          ]
        },
        {
          text: "Usage",
          items: [
            { text: "Basic Commands", link: "/guide/basic-commands" },
            { text: "Advanced Usage", link: "/guide/advanced-usage" },
          ]
        }
      ],
      "/reference/": [
        {
          text: "API Reference",
          items: [
            { text: "Configuration", link: "/reference/configuration" },
            { text: "Commands", link: "/reference/commands" },
          ]
        }
      ]
    },
    socialLinks: [
      { icon: "github", link: "https://github.com/dunnoconz/pears" }
    ]
  }
}
