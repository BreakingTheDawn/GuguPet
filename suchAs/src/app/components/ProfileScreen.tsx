import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import {
  BookOpen,
  CheckSquare,
  X,
  ChevronRight,
  Bell,
  Phone,
  Receipt,
  Info,
  MessageSquare,
  LogOut,
  Lock,
  Check,
} from "lucide-react";
import birdImg from "figma:asset/0cc679ce443880c7f323ac5b0b65175c8b133bd3.png";

// ── Data ────────────────────────────────────────────────────
const encouragements = [
  "今天也要加油！💪",
  "你是最棒的求职者！✨",
  "离梦想又近了一步~",
  "咕咕爱你！❤️",
  "每一步都算数的！🌟",
];

const graduationTasks = [
  { id: 1, label: "毕业论文初稿完成", category: "论文", emoji: "📝" },
  { id: 2, label: "论文查重通过（≤30%）", category: "论文", emoji: "📄" },
  { id: 3, label: "论文答辩完成", category: "论文", emoji: "🎤" },
  { id: 4, label: "签订三方就业协议", category: "签约", emoji: "📋" },
  { id: 5, label: "学信网毕业证书核验", category: "学历", emoji: "🎓" },
  { id: 6, label: "完成毕业证领取", category: "学历", emoji: "🏆" },
  { id: 7, label: "社保公积金缴纳完成", category: "手续", emoji: "🏦" },
  { id: 8, label: "集体户口迁移办理", category: "手续", emoji: "🏠" },
  { id: 9, label: "完成入职报到", category: "入职", emoji: "💼" },
  { id: 10, label: "公积金开户", category: "入职", emoji: "🔑" },
];

const purchasedCourses = [
  { id: 1, title: "《毕业补贴完整领取手册》", date: "2026-03-10", price: "¥9.9" },
  { id: 2, title: "《考公小白完全入门手册》", date: "2026-03-14", price: "¥19.9" },
];

const petModes = [
  { id: "seek", label: "求职态", desc: "活力满满，全力冲刺", emoji: "🔥" },
  { id: "work", label: "职场态", desc: "稳重从容，专业感满分", emoji: "💼" },
  { id: "rest", label: "休息态", desc: "放松一下，好好充电", emoji: "☕" },
];

const categoryColors: Record<string, { bg: string; text: string }> = {
  论文: { bg: "#FFE8F0", text: "#C05878" },
  签约: { bg: "#E8F0FF", text: "#4060C8" },
  学历: { bg: "#FFF0E0", text: "#C07030" },
  手续: { bg: "#E8FFE8", text: "#308050" },
  入职: { bg: "#F0E8FF", text: "#7040C0" },
};

const settingsItems = [
  { icon: Receipt, label: "订单 / 支付记录", sub: "查看已购内容与开票入口", color: "#6C5CE7" },
  { icon: Bell, label: "消息通知设置", sub: "重要节点提醒，不打扰原则", color: "#5BA4CF" },
  { icon: Phone, label: "手机号绑定", sub: "未绑定", color: "#27AE60" },
  { icon: Info, label: "关于职宠小窝", sub: "v1.0.0", color: "#F39C12" },
  { icon: MessageSquare, label: "意见反馈", sub: "帮助我们做得更好", color: "#9B59B6" },
];

// ── Progress Modal ───────────────────────────────────────────
function ProgressModal({ onClose }: { onClose: () => void }) {
  const [done, setDone] = useState<Record<number, boolean>>({ 1: true, 2: true });

  const toggle = (id: number) => setDone((prev) => ({ ...prev, [id]: !prev[id] }));
  const completedCount = Object.values(done).filter(Boolean).length;
  const pct = Math.round((completedCount / graduationTasks.length) * 100);

  return (
    <>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        onClick={onClose}
        style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.4)", backdropFilter: "blur(6px)", zIndex: 40 }}
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
          maxHeight: "78%",
          zIndex: 50,
          display: "flex",
          flexDirection: "column",
        }}
      >
        <div style={{ display: "flex", justifyContent: "center", padding: "12px 0 4px" }}>
          <div style={{ width: "36px", height: "4px", borderRadius: "2px", background: "#D8D0F0" }} />
        </div>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "8px 20px 12px" }}>
          <div>
            <h3 style={{ fontSize: "16px", fontWeight: 700, color: "#2a1a4a" }}>毕业进度 🎓</h3>
            <p style={{ fontSize: "11px", color: "#A090C8", marginTop: "1px" }}>
              {completedCount}/{graduationTasks.length} 已完成
            </p>
          </div>
          <button onClick={onClose}>
            <X size={20} color="#C0B8D8" />
          </button>
        </div>

        {/* Progress bar */}
        <div style={{ padding: "0 20px 14px" }}>
          <div style={{ background: "#EEE8FF", borderRadius: "6px", height: "8px", overflow: "hidden" }}>
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${pct}%` }}
              transition={{ duration: 0.8, ease: "easeOut" }}
              style={{
                height: "100%",
                borderRadius: "6px",
                background: "linear-gradient(90deg, #6C5CE7, #A084E8)",
              }}
            />
          </div>
          <p style={{ fontSize: "10px", color: "#A090C8", marginTop: "4px", textAlign: "right" }}>
            {pct}% 完成
          </p>
        </div>

        {/* Task list */}
        <div style={{ overflowY: "auto", padding: "0 20px 28px", flex: 1 }}>
          {graduationTasks.map((task, i) => {
            const isDone = !!done[task.id];
            const cat = categoryColors[task.category];
            return (
              <motion.button
                key={task.id}
                initial={{ opacity: 0, x: -8 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: i * 0.04 }}
                whileTap={{ scale: 0.98 }}
                onClick={() => toggle(task.id)}
                style={{
                  width: "100%",
                  display: "flex",
                  alignItems: "center",
                  gap: "12px",
                  background: isDone ? "rgba(108,92,231,0.05)" : "white",
                  borderRadius: "16px",
                  padding: "12px 14px",
                  marginBottom: "8px",
                  border: isDone ? "1px solid rgba(108,92,231,0.15)" : "1px solid #F0ECF8",
                  textAlign: "left",
                  transition: "all 0.2s",
                }}
              >
                <div
                  style={{
                    width: "26px",
                    height: "26px",
                    borderRadius: "8px",
                    background: isDone ? "#6C5CE7" : "#F0ECF8",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    flexShrink: 0,
                    transition: "background 0.2s",
                  }}
                >
                  {isDone ? <Check size={14} color="white" strokeWidth={2.5} /> : <span style={{ fontSize: "12px", opacity: 0.4 }}>○</span>}
                </div>
                <div style={{ flex: 1 }}>
                  <span style={{ fontSize: "13px", fontWeight: isDone ? 500 : 600, color: isDone ? "#888" : "#2a1a4a", textDecoration: isDone ? "line-through" : "none" }}>
                    {task.emoji} {task.label}
                  </span>
                </div>
                <span
                  style={{
                    fontSize: "9px",
                    padding: "2px 7px",
                    borderRadius: "8px",
                    background: cat.bg,
                    color: cat.text,
                    fontWeight: 600,
                    flexShrink: 0,
                  }}
                >
                  {task.category}
                </span>
              </motion.button>
            );
          })}
        </div>
      </motion.div>
    </>
  );
}

// ── Pet Modal ────────────────────────────────────────────────
function PetModal({ onClose }: { onClose: () => void }) {
  const [activePet, setActivePet] = useState("seek");
  const [showRecord, setShowRecord] = useState(false);

  const pastEncouragements = [
    { text: "你已经很棒了，咕咕都支持你 ✨", date: "3月16日" },
    { text: "累了就歇歇，明天继续 🤍", date: "3月14日" },
    { text: "面试通过啦！咕咕为你超开心 🎉", date: "3月12日" },
    { text: "迷茫也没关系，每步都算数 🌟", date: "3月10日" },
  ];

  return (
    <>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        onClick={onClose}
        style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.4)", backdropFilter: "blur(6px)", zIndex: 40 }}
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
          padding: "0 20px 36px",
          zIndex: 50,
        }}
      >
        <div style={{ display: "flex", justifyContent: "center", padding: "12px 0 4px" }}>
          <div style={{ width: "36px", height: "4px", borderRadius: "2px", background: "#D8D0F0" }} />
        </div>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: "18px" }}>
          <h3 style={{ fontSize: "16px", fontWeight: 700, color: "#2a1a4a" }}>宠物中心 🐧</h3>
          <button onClick={onClose}><X size={20} color="#C0B8D8" /></button>
        </div>

        {/* Current pet display */}
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            marginBottom: "20px",
            background: "linear-gradient(135deg, #F0EEFF, #EAE4FF)",
            borderRadius: "24px",
            padding: "20px",
          }}
        >
          <motion.img
            src={birdImg}
            alt="咕咕鸟"
            animate={{ y: [0, -8, 0], rotateY: [-10, 10, -10] }}
            transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
            style={{ width: "90px", height: "auto" }}
          />
          <p style={{ fontSize: "13px", fontWeight: 700, color: "#5040A0", marginTop: "8px" }}>
            咕咕鸟 · {petModes.find((m) => m.id === activePet)?.label}
          </p>
        </div>

        {/* Mode selector */}
        <p style={{ fontSize: "11px", color: "#A090C8", fontWeight: 600, marginBottom: "8px" }}>切换状态</p>
        <div style={{ display: "flex", gap: "8px", marginBottom: "18px" }}>
          {petModes.map((mode) => (
            <motion.button
              key={mode.id}
              whileTap={{ scale: 0.93 }}
              onClick={() => setActivePet(mode.id)}
              style={{
                flex: 1,
                padding: "10px 6px",
                borderRadius: "16px",
                background: activePet === mode.id ? "#6C5CE7" : "rgba(108,92,231,0.07)",
                border: activePet === mode.id ? "none" : "1px solid rgba(108,92,231,0.15)",
                textAlign: "center",
                transition: "background 0.2s",
              }}
            >
              <p style={{ fontSize: "18px" }}>{mode.emoji}</p>
              <p style={{ fontSize: "11px", fontWeight: 600, color: activePet === mode.id ? "white" : "#5040A0", marginTop: "2px" }}>
                {mode.label}
              </p>
            </motion.button>
          ))}
        </div>

        {/* Past encouragements toggle */}
        <button
          onClick={() => setShowRecord(!showRecord)}
          style={{
            width: "100%",
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            padding: "12px 0",
            borderTop: "1px solid #EEE8FF",
          }}
        >
          <span style={{ fontSize: "13px", color: "#5040A0", fontWeight: 600 }}>往期鼓励文案记录 💬</span>
          <span style={{ fontSize: "11px", color: "#A090C8" }}>{showRecord ? "收起 ▲" : "展开 ▼"}</span>
        </button>
        <AnimatePresence>
          {showRecord && (
            <motion.div
              initial={{ height: 0, opacity: 0 }}
              animate={{ height: "auto", opacity: 1 }}
              exit={{ height: 0, opacity: 0 }}
              style={{ overflow: "hidden" }}
            >
              {pastEncouragements.map((rec, i) => (
                <div key={i} style={{ padding: "8px 0", borderBottom: "1px solid #F5F0FF" }}>
                  <p style={{ fontSize: "12px", color: "#4a4060", lineHeight: 1.6 }}>{rec.text}</p>
                  <p style={{ fontSize: "10px", color: "#C0B8D8", marginTop: "2px" }}>{rec.date}</p>
                </div>
              ))}
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </>
  );
}

// ── Bought Modal ─────────────────────────────────────────────
function BoughtModal({ onClose }: { onClose: () => void }) {
  return (
    <>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        onClick={onClose}
        style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.4)", backdropFilter: "blur(6px)", zIndex: 40 }}
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
          padding: "0 20px 36px",
          zIndex: 50,
        }}
      >
        <div style={{ display: "flex", justifyContent: "center", padding: "12px 0 4px" }}>
          <div style={{ width: "36px", height: "4px", borderRadius: "2px", background: "#D8D0F0" }} />
        </div>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: "16px" }}>
          <h3 style={{ fontSize: "16px", fontWeight: 700, color: "#2a1a4a" }}>已购专栏 📚</h3>
          <button onClick={onClose}><X size={20} color="#C0B8D8" /></button>
        </div>

        {purchasedCourses.length === 0 ? (
          <div style={{ textAlign: "center", padding: "40px 0", color: "#C0B8D8", fontSize: "14px" }}>
            还没有购买专栏哦~<br />去知识补给站看看吧 📖
          </div>
        ) : (
          <div style={{ display: "flex", flexDirection: "column", gap: "10px" }}>
            {purchasedCourses.map((course) => (
              <motion.div
                key={course.id}
                whileTap={{ scale: 0.98 }}
                style={{
                  background: "linear-gradient(135deg, #F0EEFF, #EAE4FF)",
                  borderRadius: "18px",
                  padding: "14px 16px",
                  display: "flex",
                  alignItems: "center",
                  gap: "12px",
                }}
              >
                <div
                  style={{
                    width: "42px",
                    height: "42px",
                    borderRadius: "12px",
                    background: "#6C5CE7",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    flexShrink: 0,
                  }}
                >
                  <BookOpen size={20} color="white" />
                </div>
                <div style={{ flex: 1 }}>
                  <p style={{ fontSize: "13px", fontWeight: 600, color: "#2a1a4a", lineHeight: 1.4 }}>
                    {course.title}
                  </p>
                  <p style={{ fontSize: "10px", color: "#A090C8", marginTop: "2px" }}>
                    购买于 {course.date} · {course.price}
                  </p>
                </div>
                <ChevronRight size={16} color="#A090D8" />
              </motion.div>
            ))}
          </div>
        )}

        <div
          style={{
            marginTop: "16px",
            padding: "12px 16px",
            background: "rgba(108,92,231,0.06)",
            borderRadius: "14px",
            display: "flex",
            alignItems: "center",
            gap: "8px",
          }}
        >
          <Lock size={14} color="#A090D8" />
          <p style={{ fontSize: "11px", color: "#8070B8" }}>所有内容均支持离线查看，已加密保护</p>
        </div>
      </motion.div>
    </>
  );
}

// ── Main Screen ──────────────────────────────────────────────
export function ProfileScreen() {
  const [birdState, setBirdState] = useState<"idle" | "dancing">("idle");
  const [birdMsg, setBirdMsg] = useState("");
  const [showBirdMsg, setShowBirdMsg] = useState(false);
  const [modal, setModal] = useState<"progress" | "pet" | "bought" | null>(null);

  const handleBirdTap = () => {
    const msg = encouragements[Math.floor(Math.random() * encouragements.length)];
    setBirdMsg(msg);
    setShowBirdMsg(true);
    setBirdState("dancing");
    setTimeout(() => {
      setBirdState("idle");
      setShowBirdMsg(false);
    }, 3200);
  };

  return (
    <div style={{ background: "linear-gradient(180deg, #FDFAFF 0%, #F5F0FF 100%)", minHeight: "100%" }}>

      {/* ── Top: User + Bird ──────────────────────────────── */}
      <div
        style={{
          padding: "28px 24px 24px",
          display: "flex",
          alignItems: "flex-end",
          justifyContent: "center",
          position: "relative",
          background: "linear-gradient(180deg, white 0%, #FDFAFF 100%)",
        }}
      >
        {/* User avatar + name */}
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
          <motion.div
            style={{
              width: "80px",
              height: "80px",
              borderRadius: "50%",
              background: "linear-gradient(135deg, #6C5CE7, #A084E8)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: "30px",
              boxShadow: "0 8px 28px rgba(108,92,231,0.3)",
            }}
            whileTap={{ scale: 0.93 }}
          >
            🐧
          </motion.div>
          <p style={{ fontSize: "16px", fontWeight: 700, color: "#2a1a4a", marginTop: "10px" }}>咕咕用户</p>
          <p style={{ fontSize: "11px", color: "#B0A0C8", marginTop: "3px" }}>求职中 · 2026届毕业生</p>
        </div>

        {/* Interactive bird companion */}
        <div
          style={{ position: "absolute", right: "28px", bottom: "20px", cursor: "pointer" }}
          onClick={handleBirdTap}
        >
          {/* Encouragement bubble */}
          <AnimatePresence>
            {showBirdMsg && (
              <motion.div
                initial={{ opacity: 0, scale: 0.7, y: 8 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.7, y: 8 }}
                style={{
                  position: "absolute",
                  bottom: "90px",
                  right: "-8px",
                  background: "linear-gradient(135deg, #6C5CE7, #9B84E8)",
                  color: "white",
                  borderRadius: "14px",
                  padding: "8px 12px",
                  fontSize: "11px",
                  fontWeight: 600,
                  whiteSpace: "nowrap",
                  boxShadow: "0 6px 20px rgba(108,92,231,0.3)",
                }}
              >
                {birdMsg}
                {/* Bubble tail */}
                <div
                  style={{
                    position: "absolute",
                    bottom: "-7px",
                    right: "20px",
                    width: 0,
                    height: 0,
                    borderStyle: "solid",
                    borderWidth: "7px 5px 0",
                    borderColor: "#9B84E8 transparent transparent",
                  }}
                />
              </motion.div>
            )}
          </AnimatePresence>

          <motion.div
            animate={
              birdState === "dancing"
                ? { rotate: [-10, 12, -10, 12, 0], scale: [1, 1.18, 0.95, 1.12, 1], y: [0, -14, -5, -12, 0] }
                : { y: [0, -6, 0], rotate: [-2, 2, -2] }
            }
            transition={
              birdState === "dancing"
                ? { duration: 1.6, ease: "easeInOut" }
                : { duration: 3, repeat: Infinity, ease: "easeInOut" }
            }
            style={{ perspective: "400px" }}
          >
            <img src={birdImg} alt="咕咕鸟" style={{ width: "72px", height: "auto" }} />
          </motion.div>
          <p style={{ fontSize: "9px", color: "#C0B8D8", textAlign: "center", marginTop: "2px" }}>点我~</p>
        </div>
      </div>

      {/* ── Three Core Action Buttons ────────────────────── */}
      <div style={{ padding: "0 20px 20px" }}>
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "1fr 1fr 1fr",
            gap: "10px",
            background: "white",
            borderRadius: "24px",
            padding: "18px 12px",
            boxShadow: "0 4px 24px rgba(100,80,200,0.08)",
          }}
        >
          {[
            { label: "已购专栏", icon: "📚", sub: "离线查看", modal: "bought" as const, color: "#6C5CE7" },
            { label: "宠物中心", icon: "🐧", sub: "形象切换", modal: "pet" as const, color: "#A084E8" },
            { label: "毕业进度", icon: "✅", sub: "勾选清单", modal: "progress" as const, color: "#5BA4CF" },
          ].map((item) => (
            <motion.button
              key={item.label}
              whileTap={{ scale: 0.91 }}
              onClick={() => setModal(item.modal)}
              style={{
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                gap: "6px",
                padding: "14px 4px",
                borderRadius: "18px",
                background: `${item.color}0F`,
                border: `1.5px solid ${item.color}20`,
              }}
            >
              <span style={{ fontSize: "26px" }}>{item.icon}</span>
              <p style={{ fontSize: "12px", fontWeight: 700, color: "#2a1a4a" }}>{item.label}</p>
              <p style={{ fontSize: "9px", color: "#B0A0C8" }}>{item.sub}</p>
            </motion.button>
          ))}
        </div>
      </div>

      {/* ── Settings List ────────────────────────────────── */}
      <div style={{ padding: "0 20px 24px" }}>
        <div
          style={{
            background: "white",
            borderRadius: "24px",
            overflow: "hidden",
            boxShadow: "0 4px 24px rgba(100,80,200,0.06)",
          }}
        >
          {settingsItems.map((item, i) => {
            const Icon = item.icon;
            return (
              <motion.button
                key={item.label}
                whileTap={{ background: "#F8F6FF" }}
                style={{
                  width: "100%",
                  display: "flex",
                  alignItems: "center",
                  gap: "14px",
                  padding: "14px 18px",
                  borderBottom: i < settingsItems.length - 1 ? "0.5px solid #F0ECF8" : "none",
                  textAlign: "left",
                  background: "transparent",
                }}
              >
                <div
                  style={{
                    width: "36px",
                    height: "36px",
                    borderRadius: "12px",
                    background: `${item.color}18`,
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    flexShrink: 0,
                  }}
                >
                  <Icon size={18} color={item.color} />
                </div>
                <div style={{ flex: 1 }}>
                  <p style={{ fontSize: "14px", fontWeight: 500, color: "#2a1a4a" }}>{item.label}</p>
                  <p style={{ fontSize: "11px", color: "#B0A0C8", marginTop: "1px" }}>{item.sub}</p>
                </div>
                <ChevronRight size={16} color="#D8D0F0" />
              </motion.button>
            );
          })}
        </div>

        {/* Logout */}
        <motion.button
          whileTap={{ scale: 0.98 }}
          style={{
            width: "100%",
            marginTop: "12px",
            padding: "14px",
            borderRadius: "18px",
            background: "white",
            boxShadow: "0 4px 20px rgba(100,80,200,0.06)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            gap: "8px",
          }}
        >
          <LogOut size={16} color="#C0B0C8" />
          <span style={{ fontSize: "14px", color: "#C0B0C8" }}>退出登录</span>
        </motion.button>

        <p style={{ fontSize: "10px", color: "#D0C8E0", textAlign: "center", marginTop: "16px" }}>
          职宠小窝 v1.0.0 · 专为毕业生设计 🐧
        </p>
      </div>

      {/* ── Modals ────────────────────────────────────────── */}
      <AnimatePresence>
        {modal === "progress" && <ProgressModal key="progress" onClose={() => setModal(null)} />}
        {modal === "pet" && <PetModal key="pet" onClose={() => setModal(null)} />}
        {modal === "bought" && <BoughtModal key="bought" onClose={() => setModal(null)} />}
      </AnimatePresence>
    </div>
  );
}
