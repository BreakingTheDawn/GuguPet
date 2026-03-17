import { createBrowserRouter } from "react-router";
import { Layout } from "./components/Layout";
import { HomeScreen } from "./components/HomeScreen";
import { StatsScreen } from "./components/StatsScreen";
import { ParkScreen } from "./components/ParkScreen";
import { KnowledgeScreen } from "./components/KnowledgeScreen";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: Layout,
    children: [
      { index: true, Component: HomeScreen },
      { path: "stats", Component: StatsScreen },
      { path: "park", Component: ParkScreen },
      { path: "knowledge", Component: KnowledgeScreen },
    ],
  },
]);