import { Elm } from "./Card.elm";

const flags = {
  name: "Card Title",
  description: "Card Content",
  price: {
    prefix: "$",
    amount: "12.50",
  },
  colors: [
    {
      code: "red",
      name: "Red",
      outsideImage: "red-outside.png",
      insideImage: "red-inside.png",
    },
    {
      code: "blue",
      name: "Blue",
      outsideImage: "blue-outside.png",
      insideImage: "blue-inside.png",
    },
  ],
  href: "/products/product-page.html",
  bestseller: false,
  language: {
    code: "en",
    bestseller: "Bestseller",
    showInside: "Show Inside",
    close: "Close",
  },
};

["sample-1", "sample-2", "sample-3", "sample-4"].forEach((id) =>
  Elm.Card.init({
    node: document.getElementById(id),
    flags,
  }),
);
