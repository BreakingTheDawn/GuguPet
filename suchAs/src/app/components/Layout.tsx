import { Outlet, NavLink } from "react-router";
import { Home, BarChart2, TreePine, Briefcase } from "lucide-react";

const navItems = [
  { to: "/", icon: Home, label: "倾诉室" },
  { to: "/stats", icon: BarChart2, label: "看板" },
  { to: "/park", icon: TreePine, label: "公园" },
  { to: "/jobs", icon: Briefcase, label: "岗位" },
];

export function Layout() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-300 via-slate-200 to-slate-300 flex items-center justify-center">
      <div
        className="relative overflow-hidden bg-white"
        style={{
          width: "390px",
          height: "844px",
          maxWidth: "100vw",
          maxHeight: "100svh",
          borderRadius: "44px",
          boxShadow: "0 32px 80px rgba(0,0,0,0.28), 0 0 0 1px rgba(0,0,0,0.05)",
        }}
      >
        {/* Content area */}
        <div
          className="absolute inset-0 overflow-y-auto overflow-x-hidden"
          style={{ bottom: "64px" }}
        >
          <Outlet />
        </div>

        {/* Bottom Navigation */}
        <div
          className="absolute bottom-0 left-0 right-0 flex items-center"
          style={{
            height: "64px",
            background: "rgba(255,255,255,0.85)",
            backdropFilter: "blur(24px)",
            borderTop: "1px solid rgba(0,0,0,0.07)",
          }}
        >
          {navItems.map(({ to, icon: Icon, label }) => (
            <NavLink
              key={to}
              to={to}
              end={to === "/"}
              className={({ isActive }) =>
                `flex-1 flex flex-col items-center justify-center gap-0.5 py-2 transition-all duration-200 ${
                  isActive ? "text-indigo-500" : "text-gray-400"
                }`
              }
            >
              {({ isActive }) => (
                <>
                  <Icon
                    size={22}
                    strokeWidth={isActive ? 2.5 : 1.5}
                    className="transition-transform duration-200"
                    style={{ transform: isActive ? "scale(1.1)" : "scale(1)" }}
                  />
                  <span style={{ fontSize: "10px", fontWeight: isActive ? 600 : 400 }}>
                    {label}
                  </span>
                </>
              )}
            </NavLink>
          ))}
        </div>

        {/* Phone frame highlight */}
        <div
          className="absolute inset-0 pointer-events-none"
          style={{
            borderRadius: "inherit",
            boxShadow: "inset 0 1px 0 rgba(255,255,255,0.6)",
          }}
        />
      </div>
    </div>
  );
}