import { createBrowserRouter } from "react-router";
import { Layout } from "./components/Layout";
import { HomeScreen } from "./components/HomeScreen";
import { StatsScreen } from "./components/StatsScreen";
import { KnowledgeScreen } from "./components/KnowledgeScreen";
import { ProfileScreen } from "./components/ProfileScreen";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: Layout,
    children: [
      { index: true, Component: HomeScreen },
      { path: "stats", Component: StatsScreen },
      { path: "knowledge", Component: KnowledgeScreen },
      { path: "profile", Component: ProfileScreen },
    ],
  },
]);
