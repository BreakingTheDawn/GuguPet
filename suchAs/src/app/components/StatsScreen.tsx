import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "motion/react";
import {
  AreaChart,
  Area,
  XAxis,
  Tooltip,
  ResponsiveContainer,
} from "recharts";

const weekData = [
  { day: "周一", submissions: 8, interviews: 1 },
  { day: "周二", submissions: 12, interviews: 2 },
  { day: "周三", submissions: 5, interviews: 0 },
  { day: "周四", submissions: 15, interviews: 3 },
  { day: "周五", submissions: 9, interviews: 1 },
  { day: "周六", submissions: 3, interviews: 0 },
  { day: "周日", submissions: 12, interviews: 2 },
];

const badges = [
  {
    id: 1,
    name: "百折不挠",
    desc: "累计投递100份",
    emoji: "💪",
    unlocked: true,
    color: "#F5C5A0",
    glowColor: "rgba(245,150,80,0.5)",
  },
  {
    id: 2,
    name: "面试达人",
    desc: "完成10次面试",
    emoji: "🎯",
    unlocked: true,
    color: "#A8D4E8",
    glowColor: "rgba(80,160,220,0.5)",
  },
  {
    id: 3,
    name: "社交蝴蝶",
    desc: "公园结交5位好友",
    emoji: "🦋",
    unlocked: false,
    color: "#D0B8E8",
    glowColor: "rgba(160,100,220,0.4)",
  },
  {
    id: 4,
    name: "Offer猎手",
    desc: "斩获3个Offer",
    emoji: "🏆",
    unlocked: false,
    color: "#A8D4A8",
    glowColor: "rgba(80,180,80,0.4)",
  },
];

function AnimatedNumber({ target, duration = 1200 }: { target: number; duration?: number }) {
  const [current, setCurrent] = useState(0);
  useEffect(() => {
    const start = Date.now();
    const tick = () => {
      const elapsed = Date.now() - start;
      const progress = Math.min(elapsed / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      setCurrent(Math.round(eased * target));
      if (progress < 1) requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  }, [target, duration]);
  return <span>{current}</span>;
}

const CustomTooltip = ({ active, payload, label }: any) => {
  if (active && payload && payload.length) {
    return (
      <div
        className="rounded-2xl px-4 py-2 text-center"
        style={{
          background: "rgba(255,255,255,0.95)",
          boxShadow: "0 8px 24px rgba(0,0,0,0.12)",
          border: "none",
          fontSize: "12px",
          color: "#666",
        }}
      >
        <p style={{ fontWeight: 600, color: "#4A6A9E" }}>{label}</p>
        <p>投递 {payload[0]?.value} 份</p>
      </div>
    );
  }
  return null;
};

export function StatsScreen() {
  return (
    <div
      className="w-full pb-8"
      style={{ background: "#F7F8FC", minHeight: "100%" }}
    >
      {/* Header */}
      <div
        className="px-5 pt-10 pb-5"
        style={{
          background: "linear-gradient(160deg, #667EEA 0%, #764BA2 100%)",
        }}
      >
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
        >
          <p className="text-white/70 tracking-widest mb-1" style={{ fontSize: "11px" }}>
            今日战报
          </p>
          <h1
            className="text-white"
            style={{ fontSize: "22px", fontWeight: 700, lineHeight: 1.3 }}
          >
            坚持就是胜利 ✨
          </h1>
          <p className="text-white/60 mt-1" style={{ fontSize: "12px" }}>
            2026年3月16日 · 周一
          </p>
        </motion.div>

        {/* Stats row */}
        <div className="grid grid-cols-3 gap-3 mt-5">
          {[
            { label: "投递数", value: 128, unit: "份", bg: "rgba(255,180,120,0.25)", border: "rgba(255,160,80,0.4)", color: "#FFD4A0" },
            { label: "面试数", value: 14, unit: "次", bg: "rgba(160,210,240,0.25)", border: "rgba(120,190,230,0.4)", color: "#B8E4FF" },
            { label: "Offer数", value: 2, unit: "个", bg: "rgba(160,220,160,0.25)", border: "rgba(120,200,120,0.4)", color: "#B8F0C0" },
          ].map((stat, i) => (
            <motion.div
              key={stat.label}
              initial={{ opacity: 0, scale: 0.85 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: i * 0.1 + 0.2 }}
              className="rounded-2xl px-3 py-4 text-center"
              style={{
                background: stat.bg,
                border: `1.5px solid ${stat.border}`,
              }}
            >
              <p
                className="text-white"
                style={{ fontSize: "28px", fontWeight: 700, lineHeight: 1 }}
              >
                <AnimatedNumber target={stat.value} duration={1000 + i * 200} />
              </p>
              <p className="text-white/80 mt-1" style={{ fontSize: "10px" }}>
                {stat.label}
              </p>
            </motion.div>
          ))}
        </div>
      </div>

      {/* Chart card */}
      <motion.div
        initial={{ opacity: 0, y: 16 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4 }}
        className="mx-4 mt-4 rounded-3xl p-5"
        style={{
          background: "white",
          boxShadow: "0 4px 24px rgba(0,0,0,0.07)",
        }}
      >
        <div className="flex items-center justify-between mb-4">
          <div>
            <h3 style={{ fontSize: "15px", fontWeight: 600, color: "#2a2a3a" }}>
              本周行动轨迹
            </h3>
            <p style={{ fontSize: "11px", color: "#aaa", marginTop: "2px" }}>
              持续输出，好运自来
            </p>
          </div>
          <div
            className="rounded-full px-3 py-1"
            style={{ background: "#EEF2FF", fontSize: "11px", color: "#667EEA" }}
          >
            近7天
          </div>
        </div>

        <ResponsiveContainer width="100%" height={140}>
          <AreaChart data={weekData} margin={{ top: 8, right: 8, bottom: 0, left: -20 }}>
            <defs>
              <linearGradient id="submitGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#667EEA" stopOpacity={0.35} />
                <stop offset="95%" stopColor="#667EEA" stopOpacity={0} />
              </linearGradient>
            </defs>
            <XAxis
              dataKey="day"
              axisLine={false}
              tickLine={false}
              tick={{ fill: "#C0C0D0", fontSize: 10 }}
            />
            <Tooltip content={<CustomTooltip />} />
            <Area
              type="monotone"
              dataKey="submissions"
              stroke="#667EEA"
              fill="url(#submitGrad)"
              strokeWidth={2.5}
              dot={{ fill: "#667EEA", r: 4, strokeWidth: 0 }}
              activeDot={{ r: 6, fill: "#764BA2" }}
            />
          </AreaChart>
        </ResponsiveContainer>
      </motion.div>

      {/* Progress bars */}
      <motion.div
        initial={{ opacity: 0, y: 16 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.55 }}
        className="mx-4 mt-4 rounded-3xl p-5"
        style={{ background: "white", boxShadow: "0 4px 24px rgba(0,0,0,0.07)" }}
      >
        <h3 className="mb-4" style={{ fontSize: "15px", fontWeight: 600, color: "#2a2a3a" }}>
          阶段进度
        </h3>
        {[
          { label: "简历投递", current: 128, target: 200, color: "#F5A87A" },
          { label: "面试通过", current: 14, target: 20, color: "#7AB8E8" },
          { label: "Offer目标", current: 2, target: 3, color: "#7ACA7A" },
        ].map((item, i) => (
          <div key={item.label} className="mb-3 last:mb-0">
            <div className="flex items-center justify-between mb-1.5">
              <span style={{ fontSize: "12px", color: "#666" }}>{item.label}</span>
              <span style={{ fontSize: "11px", color: "#aaa" }}>
                {item.current} / {item.target}
              </span>
            </div>
            <div
              className="rounded-full overflow-hidden"
              style={{ height: "8px", background: "#F0F0F6" }}
            >
              <motion.div
                initial={{ width: 0 }}
                animate={{ width: `${Math.min((item.current / item.target) * 100, 100)}%` }}
                transition={{ delay: 0.6 + i * 0.15, duration: 1, ease: "easeOut" }}
                className="h-full rounded-full"
                style={{ background: item.color }}
              />
            </div>
          </div>
        ))}
      </motion.div>

      {/* Badge wall */}
      <motion.div
        initial={{ opacity: 0, y: 16 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.7 }}
        className="mx-4 mt-4 rounded-3xl p-5"
        style={{ background: "white", boxShadow: "0 4px 24px rgba(0,0,0,0.07)" }}
      >
        <div className="flex items-center justify-between mb-4">
          <h3 style={{ fontSize: "15px", fontWeight: 600, color: "#2a2a3a" }}>
            我的勋章墙
          </h3>
          <span style={{ fontSize: "11px", color: "#aaa" }}>2/4 已解锁</span>
        </div>

        <div className="grid grid-cols-2 gap-3">
          {badges.map((badge, i) => (
            <motion.div
              key={badge.id}
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: 0.75 + i * 0.1, type: "spring", stiffness: 300 }}
              className="rounded-3xl p-4 flex flex-col items-center gap-2 relative overflow-hidden"
              style={{
                background: badge.unlocked ? `${badge.color}33` : "#F5F5F8",
                border: `1.5px solid ${badge.unlocked ? badge.color : "transparent"}`,
                filter: badge.unlocked ? "none" : "grayscale(1)",
                opacity: badge.unlocked ? 1 : 0.45,
              }}
            >
              {/* Glow effect for unlocked */}
              {badge.unlocked && (
                <motion.div
                  className="absolute inset-0 rounded-3xl pointer-events-none"
                  animate={{
                    boxShadow: [
                      `inset 0 0 0px ${badge.glowColor}`,
                      `inset 0 0 20px ${badge.glowColor}`,
                      `inset 0 0 0px ${badge.glowColor}`,
                    ],
                  }}
                  transition={{ duration: 2.5, repeat: Infinity, ease: "easeInOut" }}
                />
              )}

              <span style={{ fontSize: "32px" }}>{badge.emoji}</span>
              <div className="text-center">
                <p style={{ fontSize: "13px", fontWeight: 600, color: "#3a3a5a" }}>
                  {badge.name}
                </p>
                <p style={{ fontSize: "10px", color: "#999", marginTop: "2px" }}>
                  {badge.desc}
                </p>
              </div>

              {badge.unlocked && (
                <motion.div
                  className="absolute top-2 right-2"
                  animate={{ rotate: [0, 15, -15, 0] }}
                  transition={{ duration: 3, repeat: Infinity, delay: i * 0.5 }}
                  style={{ fontSize: "10px" }}
                >
                  ✨
                </motion.div>
              )}
            </motion.div>
          ))}
        </div>

        <p
          className="text-center mt-4"
          style={{ fontSize: "11px", color: "#c0b8d8" }}
        >
          继续努力，解锁更多成就 🌟
        </p>
      </motion.div>
    </div>
  );
}
