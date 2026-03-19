import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Plus, X, ChevronRight, ChevronsUp, ChevronsDown } from "lucide-react";
import birdImg from "figma:asset/0cc679ce443880c7f323ac5b0b65175c8b133bd3.png";

// ── Types ───────────────────────────────────────────────────
interface Countdown {
  id: number;
  label: string;
  date: string;
  emoji: string;
  catBg: string;
  textColor: string;
}

// ── Helpers ─────────────────────────────────────────────────
function getDaysUntil(dateStr: string): number {
  const target = new Date(dateStr);
  const now = new Date();
  now.setHours(0, 0, 0, 0);
  return Math.max(0, Math.ceil((target.getTime() - now.getTime()) / 86400000));
}

// ── Data ────────────────────────────────────────────────────
const defaultCountdowns: Countdown[] = [
  { id: 1, label: "距毕业", date: "2026-06-20", emoji: "🎓", catBg: "#FFE2EE", textColor: "#C05A78" },
  { id: 2, label: "入职报到", date: "2026-07-15", emoji: "💼", catBg: "#E2EEFF", textColor: "#4A68C8" },
  { id: 3, label: "三方截止", date: "2026-04-30", emoji: "📋", catBg: "#E2FFE8", textColor: "#3A8A50" },
];

const quickActions = [
  { id: 1, emoji: "📄", title: "论文查重", sub: "知网 / 维普", bg: "#FFF3E8", color: "#C06020" },
  { id: 2, emoji: "📋", title: "三方协议", sub: "查看状态", bg: "#E8F0FF", color: "#4060C8" },
  { id: 3, emoji: "🏦", title: "社保查询", sub: "参保记录", bg: "#E8FFF0", color: "#208050" },
  { id: 4, emoji: "🏠", title: "公积金", sub: "开户进度", bg: "#F5E8FF", color: "#8040C0" },
];

const recommendations = [
  { id: 1, emoji: "📋", title: "毕业手续\n办理指南", reason: "距答辩仅7天", urgency: "high", bg: "#FFE8F0", accentColor: "#E05080" },
  { id: 2, emoji: "🏦", title: "社保缴纳\n完整攻略", reason: "入职前必看", urgency: "medium", bg: "#E8F0FF", accentColor: "#5080E0" },
  { id: 3, emoji: "📝", title: "三方协议\n避坑手册", reason: "签约高峰期", urgency: "high", bg: "#E8FFE8", accentColor: "#40A060" },
  { id: 4, emoji: "💰", title: "补贴领取\n申请指南", reason: "截止倒计时", urgency: "critical", bg: "#FFF0E0", accentColor: "#E07030" },
];

const birdTips = [
  "今天记得查社保缴纳状态哦~ 🏦",
  "三方协议红线处仔细看看哦！📋",
  "毕业手续清单核对了没？🎓",
  "补贴申请别拖延，快去领！💰",
  "论文查重记得提前预约呀~ 📄",
  "公积金开户跟HR确认一下✅",
];

const presetCountdowns = [
  { label: "省考报名", date: "2026-04-25", emoji: "📮" },
  { label: "补贴申请截止", date: "2026-05-31", emoji: "💰" },
  { label: "公积金截止", date: "2026-04-20", emoji: "🏠" },
];

// ── Animated Number ──────────────────────────────────────────
function AnimatedNumber({ target }: { target: number }) {
  const [cur, setCur] = useState(0);
  useEffect(() => {
    const start = Date.now();
    const dur = 900;
    const tick = () => {
      const t = Math.min((Date.now() - start) / dur, 1);
      const eased = 1 - Math.pow(1 - t, 3);
      setCur(Math.round(eased * target));
      if (t < 1) requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  }, [target]);
  return <span>{cur}</span>;
}

// ── Compact Strip ────────────────────────────────────────────
function CompactStrip({ countdowns, onExpand }: { countdowns: Countdown[]; onExpand: () => void }) {
  return (
    <motion.div
      initial={{ opacity: 0, height: 0 }}
      animate={{ opacity: 1, height: "auto" }}
      exit={{ opacity: 0, height: 0 }}
      transition={{ type: "spring", stiffness: 300, damping: 28 }}
      style={{ padding: "10px 16px" }}
    >
      <div
        style={{
          background: "rgba(255,255,255,0.88)",
          backdropFilter: "blur(16px)",
          borderRadius: "20px",
          padding: "12px 16px",
          display: "flex",
          alignItems: "center",
          boxShadow: "0 4px 20px rgba(100,80,200,0.1)",
          border: "1px solid rgba(255,255,255,0.9)",
        }}
      >
        {countdowns.map((c) => (
          <div key={c.id} style={{ flex: 1, textAlign: "center" }}>
            <span style={{ fontSize: "10px" }}>{c.emoji}</span>
            <p style={{ fontSize: "22px", fontWeight: 800, color: c.textColor, lineHeight: 1 }}>
              <AnimatedNumber target={getDaysUntil(c.date)} />
            </p>
            <p style={{ fontSize: "9px", color: "#aaa", marginTop: "1px" }}>{c.label}</p>
          </div>
        ))}
        <button
          onClick={onExpand}
          style={{
            display: "flex",
            alignItems: "center",
            gap: "2px",
            fontSize: "11px",
            color: "#6C5CE7",
            fontWeight: 600,
            padding: "6px 10px",
            background: "#F0EEFF",
            borderRadius: "12px",
            flexShrink: 0,
          }}
        >
          <ChevronsUp size={14} />
          展开
        </button>
      </div>
    </motion.div>
  );
}

// ── Main Screen ──────────────────────────────────────────────
export function StatsScreen() {
  const [countdowns, setCountdowns] = useState<Countdown[]>(defaultCountdowns);
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [showAddModal, setShowAddModal] = useState(false);
  const [customLabel, setCustomLabel] = useState("");
  const [customDate, setCustomDate] = useState("");
  const [tipIndex, setTipIndex] = useState(0);
  const [actionToast, setActionToast] = useState("");
  const [showToast, setShowToast] = useState(false);

  // Rotate tips
  useEffect(() => {
    const id = setInterval(() => setTipIndex((i) => (i + 1) % birdTips.length), 5000);
    return () => clearInterval(id);
  }, []);

  const showActionToast = (msg: string) => {
    setActionToast(msg);
    setShowToast(true);
    setTimeout(() => setShowToast(false), 2200);
  };

  const addPreset = (preset: (typeof presetCountdowns)[0]) => {
    const newId = Date.now();
    const colors = [
      { catBg: "#FFF5E0", textColor: "#B07020" },
      { catBg: "#E8F4FF", textColor: "#3065B0" },
      { catBg: "#EEE8FF", textColor: "#6848C0" },
    ];
    const colorSet = colors[countdowns.length % colors.length];
    setCountdowns((prev) => [...prev, { id: newId, label: preset.label, date: preset.date, emoji: preset.emoji, ...colorSet }]);
    setShowAddModal(false);
    setCustomLabel("");
    setCustomDate("");
  };

  const addCustom = () => {
    if (!customLabel.trim() || !customDate) return;
    const newId = Date.now();
    setCountdowns((prev) => [
      ...prev,
      { id: newId, label: customLabel.trim(), date: customDate, emoji: "📅", catBg: "#F0F0F8", textColor: "#4848A0" },
    ]);
    setShowAddModal(false);
    setCustomLabel("");
    setCustomDate("");
  };

  const removeCountdown = (id: number) => {
    setCountdowns((prev) => prev.filter((c) => c.id !== id));
  };

  return (
    <div style={{ background: "linear-gradient(180deg, #F8F5FF 0%, #F4F0FF 100%)", minHeight: "100%" }}>

      {/* ── Drag handle / collapse toggle ─────────────────── */}
      <div style={{ padding: "10px 0 4px", display: "flex", justifyContent: "center", alignItems: "center", gap: "8px" }}>
        <div style={{ width: "36px", height: "4px", borderRadius: "2px", background: "#D8D0F0" }} />
        <motion.button
          whileTap={{ scale: 0.9 }}
          onClick={() => setIsCollapsed((v) => !v)}
          style={{
            display: "flex",
            alignItems: "center",
            gap: "3px",
            fontSize: "10px",
            color: "#A090C8",
            padding: "3px 8px",
            borderRadius: "10px",
            background: "rgba(180,160,220,0.12)",
          }}
        >
          {isCollapsed ? <ChevronsDown size={12} /> : <ChevronsUp size={12} />}
          {isCollapsed ? "展开看板" : "收起看板"}
        </motion.button>
        <div style={{ width: "36px", height: "4px", borderRadius: "2px", background: "#D8D0F0" }} />
      </div>

      <AnimatePresence mode="wait">
        {isCollapsed ? (
          <CompactStrip key="compact" countdowns={countdowns} onExpand={() => setIsCollapsed(false)} />
        ) : (
          <motion.div
            key="full"
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 8 }}
            transition={{ duration: 0.25 }}
          >

            {/* ── Section: Countdown ─────────────────────── */}
            <div style={{ padding: "4px 16px 0" }}>
              <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: "10px" }}>
                <div>
                  <h2 style={{ fontSize: "15px", fontWeight: 700, color: "#2a1a4a" }}>倒计时面板</h2>
                  <p style={{ fontSize: "10px", color: "#B0A0D0", marginTop: "1px" }}>滑动查看全部节点</p>
                </div>
                <motion.button
                  whileTap={{ scale: 0.88 }}
                  onClick={() => setShowAddModal(true)}
                  style={{
                    width: "32px",
                    height: "32px",
                    borderRadius: "12px",
                    background: "#6C5CE7",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    boxShadow: "0 4px 12px rgba(108,92,231,0.35)",
                  }}
                >
                  <Plus size={16} color="white" strokeWidth={2.5} />
                </motion.button>
              </div>

              {/* Countdown cards row */}
              <div style={{ display: "flex", gap: "10px", overflowX: "auto", paddingBottom: "4px", scrollbarWidth: "none" }}>
                {countdowns.map((c, i) => {
                  const days = getDaysUntil(c.date);
                  const isUrgent = days <= 14;
                  return (
                    <motion.div
                      key={c.id}
                      initial={{ opacity: 0, scale: 0.88 }}
                      animate={{ opacity: 1, scale: 1 }}
                      transition={{ delay: i * 0.07, type: "spring", stiffness: 300 }}
                      style={{
                        flexShrink: 0,
                        width: "115px",
                        borderRadius: "22px",
                        background: `linear-gradient(145deg, ${c.catBg}, white)`,
                        padding: "16px 14px",
                        backdropFilter: "blur(8px)",
                        border: "1.5px solid rgba(255,255,255,0.9)",
                        boxShadow: "0 4px 20px rgba(0,0,0,0.07)",
                        position: "relative",
                        overflow: "hidden",
                      }}
                    >
                      {/* Remove button */}
                      {countdowns.length > 1 && (
                        <button
                          onClick={() => removeCountdown(c.id)}
                          style={{
                            position: "absolute",
                            top: "8px",
                            right: "8px",
                            width: "18px",
                            height: "18px",
                            borderRadius: "50%",
                            background: "rgba(0,0,0,0.08)",
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                          }}
                        >
                          <X size={10} color="#888" />
                        </button>
                      )}
                      <span style={{ fontSize: "22px" }}>{c.emoji}</span>
                      <p
                        style={{
                          fontSize: "42px",
                          fontWeight: 800,
                          color: c.textColor,
                          lineHeight: 1.1,
                          marginTop: "6px",
                        }}
                      >
                        <AnimatedNumber target={days} />
                      </p>
                      <p style={{ fontSize: "11px", color: "#888", marginTop: "2px" }}>天</p>
                      <p style={{ fontSize: "11px", fontWeight: 600, color: "#444", marginTop: "6px" }}>{c.label}</p>
                      <p style={{ fontSize: "9px", color: "#bbb", marginTop: "2px" }}>{c.date}</p>
                      {isUrgent && (
                        <motion.div
                          animate={{ opacity: [0.6, 1, 0.6] }}
                          transition={{ duration: 1.5, repeat: Infinity }}
                          style={{
                            position: "absolute",
                            bottom: "10px",
                            right: "10px",
                            fontSize: "8px",
                            color: c.textColor,
                            fontWeight: 700,
                            background: `${c.catBg}`,
                            padding: "2px 6px",
                            borderRadius: "6px",
                          }}
                        >
                          紧迫！
                        </motion.div>
                      )}
                    </motion.div>
                  );
                })}
                {/* Add placeholder */}
                <motion.button
                  whileTap={{ scale: 0.9 }}
                  onClick={() => setShowAddModal(true)}
                  style={{
                    flexShrink: 0,
                    width: "80px",
                    borderRadius: "22px",
                    background: "rgba(255,255,255,0.6)",
                    backdropFilter: "blur(8px)",
                    border: "2px dashed rgba(108,92,231,0.3)",
                    display: "flex",
                    flexDirection: "column",
                    alignItems: "center",
                    justifyContent: "center",
                    gap: "6px",
                  }}
                >
                  <Plus size={20} color="#A090D8" />
                  <span style={{ fontSize: "10px", color: "#A090D8" }}>添加节点</span>
                </motion.button>
              </div>
            </div>

            {/* ── Section: Quick Actions ──────────────────── */}
            <div style={{ padding: "18px 16px 0" }}>
              <div style={{ marginBottom: "10px" }}>
                <h2 style={{ fontSize: "15px", fontWeight: 700, color: "#2a1a4a" }}>高频待办</h2>
                <p style={{ fontSize: "10px", color: "#B0A0D0", marginTop: "1px" }}>用完即走，直达核心诉求</p>
              </div>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "10px" }}>
                {quickActions.map((action, i) => (
                  <motion.button
                    key={action.id}
                    initial={{ opacity: 0, y: 12 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.2 + i * 0.08 }}
                    whileTap={{ scale: 0.95 }}
                    onClick={() => showActionToast(`正在打开「${action.title}」入口~`)}
                    style={{
                      background: action.bg,
                      borderRadius: "20px",
                      padding: "16px",
                      textAlign: "left",
                      border: "1px solid rgba(255,255,255,0.8)",
                      boxShadow: "0 3px 14px rgba(0,0,0,0.06)",
                    }}
                  >
                    <span style={{ fontSize: "28px", display: "block", marginBottom: "8px" }}>{action.emoji}</span>
                    <p style={{ fontSize: "13px", fontWeight: 700, color: "#2a2a3a" }}>{action.title}</p>
                    <p style={{ fontSize: "10px", color: "#999", marginTop: "2px" }}>{action.sub}</p>
                    <ChevronRight size={14} color={action.color} style={{ marginTop: "6px" }} />
                  </motion.button>
                ))}
              </div>
            </div>

            {/* ── Section: Smart Recommendations ─────────── */}
            <div style={{ padding: "18px 0 0" }}>
              <div style={{ padding: "0 16px", marginBottom: "10px", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
                <div>
                  <h2 style={{ fontSize: "15px", fontWeight: 700, color: "#2a1a4a" }}>智能推荐</h2>
                  <p style={{ fontSize: "10px", color: "#B0A0D0", marginTop: "1px" }}>根据你的毕业进度精准推送</p>
                </div>
                <span style={{ fontSize: "10px", color: "#6C5CE7", fontWeight: 600 }}>基于最近7天 →</span>
              </div>
              <div
                style={{
                  display: "flex",
                  gap: "12px",
                  overflowX: "auto",
                  padding: "4px 16px 8px",
                  scrollbarWidth: "none",
                }}
              >
                {recommendations.map((rec, i) => (
                  <motion.div
                    key={rec.id}
                    initial={{ opacity: 0, x: 16 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.3 + i * 0.1 }}
                    style={{
                      flexShrink: 0,
                      width: "120px",
                      borderRadius: "20px",
                      background: rec.bg,
                      padding: "16px 12px",
                      border: "1px solid rgba(255,255,255,0.8)",
                      boxShadow: "0 4px 16px rgba(0,0,0,0.06)",
                      position: "relative",
                    }}
                  >
                    <span style={{ fontSize: "30px", display: "block", marginBottom: "8px" }}>{rec.emoji}</span>
                    <p
                      style={{
                        fontSize: "12px",
                        fontWeight: 700,
                        color: "#2a2a3a",
                        lineHeight: 1.45,
                        whiteSpace: "pre-line",
                      }}
                    >
                      {rec.title}
                    </p>
                    <div
                      style={{
                        marginTop: "10px",
                        fontSize: "9px",
                        color: rec.accentColor,
                        background: `${rec.bg}`,
                        padding: "3px 7px",
                        borderRadius: "8px",
                        border: `1px solid ${rec.accentColor}40`,
                        display: "inline-block",
                        fontWeight: 600,
                      }}
                    >
                      {rec.urgency === "critical" ? "⚡ " : rec.urgency === "high" ? "🔔 " : ""}
                      {rec.reason}
                    </div>
                  </motion.div>
                ))}
              </div>
            </div>

            {/* ── Bird Tip Section ────────────────────────── */}
            <div style={{ padding: "10px 16px 20px" }}>
              <div
                style={{
                  display: "flex",
                  alignItems: "flex-end",
                  gap: "10px",
                  background: "rgba(255,255,255,0.75)",
                  backdropFilter: "blur(16px)",
                  borderRadius: "24px",
                  padding: "12px 16px",
                  border: "1px solid rgba(255,255,255,0.9)",
                  boxShadow: "0 4px 20px rgba(100,80,200,0.08)",
                }}
              >
                {/* Mini bird */}
                <motion.div
                  animate={{ y: [0, -6, 0], rotate: [-3, 3, -3] }}
                  transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
                  style={{ flexShrink: 0 }}
                >
                  <img src={birdImg} alt="咕咕" style={{ width: "52px", height: "auto" }} />
                </motion.div>

                {/* Speech bubble */}
                <div style={{ flex: 1, position: "relative" }}>
                  {/* Bubble tail */}
                  <div
                    style={{
                      position: "absolute",
                      left: "-8px",
                      bottom: "10px",
                      width: 0,
                      height: 0,
                      borderStyle: "solid",
                      borderWidth: "5px 8px 5px 0",
                      borderColor: "transparent rgba(108,92,231,0.12) transparent transparent",
                    }}
                  />
                  <AnimatePresence mode="wait">
                    <motion.div
                      key={tipIndex}
                      initial={{ opacity: 0, y: 4 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -4 }}
                      transition={{ duration: 0.3 }}
                      style={{
                        background: "linear-gradient(135deg, #EEE8FF, #E8E0FF)",
                        borderRadius: "16px",
                        padding: "10px 14px",
                        fontSize: "12px",
                        color: "#5040A0",
                        lineHeight: "1.65",
                        fontWeight: 500,
                      }}
                    >
                      {birdTips[tipIndex]}
                    </motion.div>
                  </AnimatePresence>
                  <p style={{ fontSize: "9px", color: "#C0B8D8", marginTop: "5px", paddingLeft: "4px" }}>
                    点击提示可切换 · 咕咕毕业小提醒
                  </p>
                </div>
              </div>
            </div>

          </motion.div>
        )}
      </AnimatePresence>

      {/* ── Toast ─────────────────────────────────────────── */}
      <AnimatePresence>
        {showToast && (
          <motion.div
            initial={{ opacity: 0, y: 16, scale: 0.9 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -8, scale: 0.92 }}
            style={{
              position: "fixed",
              bottom: "80px",
              left: "50%",
              transform: "translateX(-50%)",
              background: "rgba(42,30,80,0.88)",
              backdropFilter: "blur(12px)",
              borderRadius: "20px",
              padding: "10px 20px",
              fontSize: "12px",
              color: "white",
              whiteSpace: "nowrap",
              zIndex: 50,
            }}
          >
            {actionToast}
          </motion.div>
        )}
      </AnimatePresence>

      {/* ── Add Countdown Modal ────────────────────────────── */}
      <AnimatePresence>
        {showAddModal && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setShowAddModal(false)}
              style={{
                position: "fixed",
                inset: 0,
                background: "rgba(0,0,0,0.35)",
                backdropFilter: "blur(6px)",
                zIndex: 40,
              }}
            />
            <motion.div
              initial={{ opacity: 0, y: "100%" }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: "100%" }}
              transition={{ type: "spring", stiffness: 380, damping: 35 }}
              style={{
                position: "fixed",
                left: 0,
                right: 0,
                bottom: 0,
                borderRadius: "28px 28px 0 0",
                background: "#FDFAFF",
                padding: "0 20px 32px",
                zIndex: 50,
              }}
            >
              <div style={{ display: "flex", justifyContent: "center", padding: "12px 0 4px" }}>
                <div style={{ width: "36px", height: "4px", borderRadius: "2px", background: "#D8D0F0" }} />
              </div>
              <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: "16px" }}>
                <h3 style={{ fontSize: "16px", fontWeight: 700, color: "#2a1a4a" }}>添加关注节点</h3>
                <button onClick={() => setShowAddModal(false)}>
                  <X size={20} color="#C0B8D8" />
                </button>
              </div>

              {/* Presets */}
              <p style={{ fontSize: "11px", color: "#A090C8", marginBottom: "8px", fontWeight: 600 }}>
                快速添加
              </p>
              <div style={{ display: "flex", flexDirection: "column", gap: "8px", marginBottom: "16px" }}>
                {presetCountdowns.map((p) => (
                  <motion.button
                    key={p.label}
                    whileTap={{ scale: 0.97 }}
                    onClick={() => addPreset(p)}
                    style={{
                      display: "flex",
                      alignItems: "center",
                      gap: "12px",
                      background: "rgba(108,92,231,0.07)",
                      borderRadius: "16px",
                      padding: "12px 16px",
                      textAlign: "left",
                    }}
                  >
                    <span style={{ fontSize: "22px" }}>{p.emoji}</span>
                    <div>
                      <p style={{ fontSize: "13px", fontWeight: 600, color: "#2a1a4a" }}>{p.label}</p>
                      <p style={{ fontSize: "10px", color: "#999", marginTop: "1px" }}>{p.date}</p>
                    </div>
                    <ChevronRight size={14} color="#A090D8" style={{ marginLeft: "auto" }} />
                  </motion.button>
                ))}
              </div>

              {/* Custom */}
              <p style={{ fontSize: "11px", color: "#A090C8", marginBottom: "8px", fontWeight: 600 }}>
                自定义节点
              </p>
              <input
                value={customLabel}
                onChange={(e) => setCustomLabel(e.target.value)}
                placeholder="节点名称（如：省考报名）"
                style={{
                  width: "100%",
                  background: "rgba(108,92,231,0.06)",
                  borderRadius: "14px",
                  padding: "12px 16px",
                  fontSize: "13px",
                  color: "#2a1a4a",
                  outline: "none",
                  border: "none",
                  marginBottom: "8px",
                  boxSizing: "border-box",
                }}
              />
              <input
                type="date"
                value={customDate}
                onChange={(e) => setCustomDate(e.target.value)}
                style={{
                  width: "100%",
                  background: "rgba(108,92,231,0.06)",
                  borderRadius: "14px",
                  padding: "12px 16px",
                  fontSize: "13px",
                  color: "#2a1a4a",
                  outline: "none",
                  border: "none",
                  marginBottom: "16px",
                  boxSizing: "border-box",
                }}
              />
              <motion.button
                whileTap={{ scale: 0.97 }}
                onClick={addCustom}
                style={{
                  width: "100%",
                  padding: "14px",
                  borderRadius: "18px",
                  background: customLabel && customDate ? "linear-gradient(135deg, #6C5CE7, #A084E8)" : "#E8E0F0",
                  color: customLabel && customDate ? "white" : "#B0A0C8",
                  fontSize: "15px",
                  fontWeight: 700,
                  transition: "background 0.3s",
                }}
              >
                确认添加
              </motion.button>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}
