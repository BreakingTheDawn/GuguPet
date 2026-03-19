import { useEffect, useState } from "react";
import { Outlet, NavLink, useLocation } from "react-router";
import { Home, BarChart2, BookOpen, User } from "lucide-react";

const pageTitles: Record<string, string> = {
  "/": "倾诉室",
  "/stats": "毕业冲刺看板",
  "/knowledge": "知识补给站",
  "/profile": "我的小窝",
};

const navItems = [
  { to: "/", icon: Home, label: "倾诉室" },
  { to: "/stats", icon: BarChart2, label: "看板" },
  { to: "/knowledge", icon: BookOpen, label: "专栏" },
  { to: "/profile", icon: User, label: "我的" },
];

// Page-specific header theme
const pageThemes: Record<string, { bg: string; textColor: string; capsuleAlpha: string }> = {
  "/": { bg: "#FFF8EF", textColor: "#8070A8", capsuleAlpha: "rgba(140,110,200,0.18)" },
  "/stats": { bg: "rgba(255,255,255,0.97)", textColor: "#1a1a2e", capsuleAlpha: "rgba(0,0,0,0.07)" },
  "/knowledge": { bg: "rgba(255,255,255,0.97)", textColor: "#1a1a2e", capsuleAlpha: "rgba(0,0,0,0.07)" },
  "/profile": { bg: "rgba(255,255,255,0.97)", textColor: "#1a1a2e", capsuleAlpha: "rgba(0,0,0,0.07)" },
};

function StatusBar({ textColor }: { textColor: string }) {
  const [time, setTime] = useState(() => {
    const n = new Date();
    return `${n.getHours()}:${String(n.getMinutes()).padStart(2, "0")}`;
  });
  useEffect(() => {
    const id = setInterval(() => {
      const n = new Date();
      setTime(`${n.getHours()}:${String(n.getMinutes()).padStart(2, "0")}`);
    }, 15000);
    return () => clearInterval(id);
  }, []);

  return (
    <div
      style={{
        height: "44px",
        display: "flex",
        alignItems: "flex-end",
        justifyContent: "space-between",
        padding: "0 18px 6px",
      }}
    >
      <span
        style={{
          fontSize: "15px",
          fontWeight: 600,
          color: textColor,
          fontVariantNumeric: "tabular-nums",
        }}
      >
        {time}
      </span>
      <div style={{ display: "flex", alignItems: "center", gap: "5px" }}>
        {/* Signal bars */}
        <svg width="17" height="11" viewBox="0 0 17 11">
          <rect x="0" y="8" width="3" height="3" rx="0.6" fill={textColor} />
          <rect x="4.5" y="5.5" width="3" height="5.5" rx="0.6" fill={textColor} />
          <rect x="9" y="3" width="3" height="8" rx="0.6" fill={textColor} />
          <rect x="13.5" y="0" width="3" height="11" rx="0.6" fill={textColor} />
        </svg>
        {/* WiFi */}
        <svg width="16" height="12" viewBox="0 0 16 12">
          <circle cx="8" cy="11" r="1.5" fill={textColor} />
          <path d="M4.5 7.5C5.5 6.3 6.7 5.5 8 5.5s2.5.8 3.5 2" stroke={textColor} strokeWidth="1.4" fill="none" strokeLinecap="round" />
          <path d="M1.5 4.5C3.2 2.5 5.5 1.2 8 1.2s4.8 1.3 6.5 3.3" stroke={textColor} strokeWidth="1.4" fill="none" strokeLinecap="round" />
        </svg>
        {/* Battery */}
        <svg width="25" height="12" viewBox="0 0 25 12">
          <rect x="0.5" y="2" width="20" height="8" rx="2" stroke={textColor} strokeWidth="1.2" fill="none" />
          <rect x="2" y="3.5" width="14" height="5" rx="0.8" fill={textColor} />
          <path d="M22 4.5v3a1.2 1.2 0 0 0 0-3z" fill={textColor} />
        </svg>
      </div>
    </div>
  );
}

function WxNavBar({
  title,
  textColor,
  capsuleAlpha,
}: {
  title: string;
  textColor: string;
  capsuleAlpha: string;
}) {
  return (
    <div
      style={{
        height: "46px",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        position: "relative",
      }}
    >
      <span style={{ fontSize: "17px", fontWeight: 600, color: textColor, letterSpacing: "0.01em" }}>
        {title}
      </span>

      {/* WeChat Capsule Button (胶囊按钮) */}
      <div
        style={{
          position: "absolute",
          right: "8px",
          display: "flex",
          alignItems: "center",
          height: "32px",
          borderRadius: "16px",
          background: capsuleAlpha,
          border: `1px solid ${capsuleAlpha}`,
          overflow: "hidden",
        }}
      >
        <button
          style={{
            padding: "0 12px",
            height: "32px",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: "17px",
            color: textColor,
            lineHeight: 1,
            background: "transparent",
            letterSpacing: "1px",
          }}
        >
          ···
        </button>
        <div
          style={{ width: "0.5px", height: "14px", background: textColor, opacity: 0.2 }}
        />
        <button
          style={{
            padding: "0 10px",
            height: "32px",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: "15px",
            color: textColor,
            background: "transparent",
            opacity: 0.7,
          }}
        >
          ✕
        </button>
      </div>
    </div>
  );
}

function TabBar() {
  return (
    <div
      style={{
        height: "54px",
        display: "flex",
        background: "rgba(255,255,255,0.96)",
        backdropFilter: "blur(24px)",
        borderTop: "0.5px solid rgba(0,0,0,0.1)",
        flexShrink: 0,
      }}
    >
      {navItems.map(({ to, icon: Icon, label }) => (
        <NavLink
          key={to}
          to={to}
          end={to === "/"}
          style={({ isActive }) => ({
            flex: 1,
            display: "flex",
            flexDirection: "column" as const,
            alignItems: "center",
            justifyContent: "center",
            gap: "2px",
            color: isActive ? "#6C5CE7" : "#B0A8C8",
            textDecoration: "none",
            transition: "color 0.2s",
          })}
        >
          {({ isActive }) => (
            <>
              <Icon
                size={22}
                strokeWidth={isActive ? 2.5 : 1.5}
                style={{ transition: "transform 0.2s", transform: isActive ? "scale(1.1)" : "scale(1)" }}
              />
              <span style={{ fontSize: "10px", fontWeight: isActive ? 600 : 400 }}>
                {label}
              </span>
            </>
          )}
        </NavLink>
      ))}
    </div>
  );
}

export function Layout() {
  const location = useLocation();
  const currentTitle = pageTitles[location.pathname] ?? "职宠小窝";
  const theme = pageThemes[location.pathname] ?? pageThemes["/stats"];

  return (
    <div
      className="min-h-screen flex items-center justify-center"
      style={{ background: "linear-gradient(135deg, #D4D0E8 0%, #C8D4E8 50%, #D0C8E8 100%)" }}
    >
      <div
        style={{
          width: "390px",
          height: "844px",
          maxWidth: "100vw",
          maxHeight: "100svh",
          borderRadius: "44px",
          overflow: "hidden",
          display: "flex",
          flexDirection: "column",
          boxShadow: "0 36px 90px rgba(0,0,0,0.32), 0 0 0 1px rgba(0,0,0,0.06)",
          background: "white",
          position: "relative",
        }}
      >
        {/* WeChat-style header */}
        <div
          style={{
            background: theme.bg,
            flexShrink: 0,
            borderBottom: theme.bg.includes("rgba(255,255,255") ? "0.5px solid rgba(0,0,0,0.07)" : "none",
          }}
        >
          <StatusBar textColor={theme.textColor} />
          <WxNavBar title={currentTitle} textColor={theme.textColor} capsuleAlpha={theme.capsuleAlpha} />
        </div>

        {/* Page content */}
        <div style={{ flex: 1, overflow: "hidden", position: "relative" }}>
          <div
            id="content-scroll"
            style={{ height: "100%", overflowY: "auto", overflowX: "hidden" }}
          >
            <Outlet />
          </div>
        </div>

        {/* Tab bar */}
        <TabBar />

        {/* Frame inner highlight */}
        <div
          style={{
            position: "absolute",
            inset: 0,
            borderRadius: "44px",
            boxShadow: "inset 0 1px 0 rgba(255,255,255,0.55), inset 0 -1px 0 rgba(0,0,0,0.08)",
            pointerEvents: "none",
            zIndex: 100,
          }}
        />
      </div>
    </div>
  );
}
