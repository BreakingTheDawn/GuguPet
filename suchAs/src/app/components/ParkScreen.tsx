import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { X, ChevronDown } from "lucide-react";

function PenguinSVG({
  color = "#4A4A6A",
  accessory = "none",
  size = 70,
}: {
  color?: string;
  accessory?: string;
  size?: number;
}) {
  return (
    <svg width={size} height={size * 1.15} viewBox="0 0 60 69" fill="none">
      {/* Wings */}
      <ellipse cx="10" cy="42" rx="8" ry="13" fill={color} transform="rotate(-20 10 42)" />
      <ellipse cx="50" cy="42" rx="8" ry="13" fill={color} transform="rotate(20 50 42)" />
      {/* Body */}
      <ellipse cx="30" cy="46" rx="18" ry="20" fill={color} />
      {/* Belly */}
      <ellipse cx="30" cy="50" rx="11" ry="14" fill="#F5F5F5" />
      {/* Head */}
      <circle cx="30" cy="21" r="16" fill={color} />
      {/* Eye whites */}
      <circle cx="23.5" cy="18" r="5" fill="white" />
      <circle cx="36.5" cy="18" r="5" fill="white" />
      {/* Pupils */}
      <circle cx="24.5" cy="19" r="3" fill="#1a1a2e" />
      <circle cx="37.5" cy="19" r="3" fill="#1a1a2e" />
      {/* Eye shine */}
      <circle cx="25.5" cy="18" r="1" fill="white" />
      <circle cx="38.5" cy="18" r="1" fill="white" />
      {/* Beak */}
      <path d="M27 24 L30 30 L33 24 Z" fill="#F0A020" />
      {/* Blush */}
      <ellipse cx="20" cy="23" rx="4" ry="2.5" fill="#FFB3C6" opacity="0.5" />
      <ellipse cx="40" cy="23" rx="4" ry="2.5" fill="#FFB3C6" opacity="0.5" />
      {/* Feet */}
      <ellipse cx="24" cy="65" rx="7" ry="3" fill="#F0A020" />
      <ellipse cx="36" cy="65" rx="7" ry="3" fill="#F0A020" />

      {/* Tie */}
      {accessory === "tie" && (
        <g>
          <rect x="27.5" y="30" width="5" height="3" fill="#C0392B" rx="0.5" />
          <path d="M27 33 L30 44 L33 33 Z" fill="#C0392B" />
        </g>
      )}
      {/* Glasses */}
      {accessory === "glasses" && (
        <g>
          <circle cx="23.5" cy="18" r="6" fill="none" stroke="#4A3728" strokeWidth="1.5" />
          <circle cx="36.5" cy="18" r="6" fill="none" stroke="#4A3728" strokeWidth="1.5" />
          <line x1="29.5" y1="18" x2="30.5" y2="18" stroke="#4A3728" strokeWidth="1.5" />
          <line x1="5" y1="18" x2="17.5" y2="18" stroke="#4A3728" strokeWidth="1.5" />
          <line x1="42.5" y1="18" x2="55" y2="18" stroke="#4A3728" strokeWidth="1.5" />
        </g>
      )}
      {/* Bow */}
      {accessory === "bow" && (
        <g>
          <path d="M25 6 L30 12 L25 18 Z" fill="#FF69B4" />
          <path d="M35 6 L30 12 L35 18 Z" fill="#FF69B4" />
          <circle cx="30" cy="12" r="3.5" fill="#FF1493" />
        </g>
      )}
      {/* Hard hat */}
      {accessory === "hardhat" && (
        <g>
          <ellipse cx="30" cy="8" rx="14" ry="8" fill="#FF9500" />
          <rect x="15" y="13" width="30" height="4" rx="2" fill="#FF9500" />
        </g>
      )}
      {/* Crown */}
      {accessory === "crown" && (
        <g>
          <path d="M18 12 L22 5 L30 10 L38 5 L42 12 Z" fill="#FFD700" />
          <rect x="18" y="12" width="24" height="5" rx="1" fill="#FFD700" />
        </g>
      )}
    </svg>
  );
}

const parkBirds = [
  { id: 1, name: "码农阿贤", label: "全栈工程师", accessory: "glasses", color: "#4A78C8", x: "14%", y: "28%" },
  { id: 2, name: "设计师小美", label: "UI/UX设计师", accessory: "bow", color: "#C87AB8", x: "60%", y: "22%" },
  { id: 3, name: "产品老王", label: "产品经理", accessory: "tie", color: "#4A9E5A", x: "35%", y: "50%" },
  { id: 4, name: "运营小李", label: "品牌运营", accessory: "hardhat", color: "#C89040", x: "68%", y: "55%" },
  { id: 5, name: "HR阿珍", label: "人才招募", accessory: "crown", color: "#7A58C8", x: "18%", y: "62%" },
];

const zones = ["码农森林", "金币湖畔", "设计师草原", "产品家园"];

const encouragements = [
  "💪 你今天的努力，明天的你都看得到！每一份简历都是一颗种子",
  "🌟 别灰心，最好的Offer正在等待最棒的你！",
  "☀️ 面试官会爱上你的，就像咕咕爱你一样~",
  "🍀 运气正在赶来的路上，再等等，快了！",
  "✨ 坚持的人，最终都会发光！加油加油加油！",
];

const interactActions = [
  { emoji: "🤗", label: "贴一贴", toast: "暖暖的贴贴送出去了！" },
  { emoji: "🌸", label: "送花", toast: "一朵鲜花送给你~" },
  { emoji: "📋", label: "交换战报", toast: "战报交换成功！互相加油💪" },
];

export function ParkScreen() {
  const [selectedZone, setSelectedZone] = useState(0);
  const [showZoneMenu, setShowZoneMenu] = useState(false);
  const [selectedBird, setSelectedBird] = useState<(typeof parkBirds)[0] | null>(null);
  const [toastMsg, setToastMsg] = useState("");
  const [showToast, setShowToast] = useState(false);
  const [envelopeOpen, setEnvelopeOpen] = useState<number | null>(null);
  const [usedEnvelopes, setUsedEnvelopes] = useState<number[]>([]);

  const showToastMessage = (msg: string) => {
    setToastMsg(msg);
    setShowToast(true);
    setTimeout(() => setShowToast(false), 2500);
  };

  const handleAction = (action: (typeof interactActions)[0]) => {
    setSelectedBird(null);
    showToastMessage(action.toast);
  };

  const handleEnvelope = (idx: number) => {
    setEnvelopeOpen(idx);
    if (!usedEnvelopes.includes(idx)) {
      setUsedEnvelopes((prev) => [...prev, idx]);
    }
  };

  return (
    <div className="w-full relative" style={{ minHeight: "100%", background: "#E8F5E0" }}>
      {/* Zone header */}
      <div
        className="sticky top-0 z-30 px-5 py-4 flex items-center justify-between"
        style={{
          background: "rgba(255,255,255,0.88)",
          backdropFilter: "blur(20px)",
          borderBottom: "1px solid rgba(0,0,0,0.06)",
        }}
      >
        <div>
          <p className="text-gray-400 tracking-widest" style={{ fontSize: "10px" }}>
            当前区域
          </p>
          <button
            className="flex items-center gap-1.5 mt-0.5"
            onClick={() => setShowZoneMenu(!showZoneMenu)}
          >
            <span style={{ fontSize: "15px", fontWeight: 700, color: "#2a4a2a" }}>
              🌲 {zones[selectedZone]}
            </span>
            <motion.div animate={{ rotate: showZoneMenu ? 180 : 0 }}>
              <ChevronDown size={14} color="#666" />
            </motion.div>
          </button>
        </div>
        <div
          className="rounded-full px-3 py-1.5 text-center"
          style={{ background: "#D4EDD4", fontSize: "11px", color: "#3a7a3a" }}
        >
          <span>👥 {12 + selectedZone * 3} 只咕咕在逛</span>
        </div>
      </div>

      {/* Zone dropdown */}
      <AnimatePresence>
        {showZoneMenu && (
          <motion.div
            initial={{ opacity: 0, y: -8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            className="absolute z-40 left-5 right-5"
            style={{
              top: "76px",
              background: "white",
              borderRadius: "16px",
              boxShadow: "0 8px 32px rgba(0,0,0,0.15)",
              overflow: "hidden",
            }}
          >
            {zones.map((zone, i) => (
              <button
                key={zone}
                className="w-full px-5 py-3 text-left flex items-center gap-3 hover:bg-gray-50 transition-colors"
                style={{
                  borderBottom: i < zones.length - 1 ? "1px solid #f0f0f0" : "none",
                  fontSize: "14px",
                  color: selectedZone === i ? "#3a7a3a" : "#444",
                  fontWeight: selectedZone === i ? 600 : 400,
                }}
                onClick={() => {
                  setSelectedZone(i);
                  setShowZoneMenu(false);
                }}
              >
                {["🌲", "💰", "🎨", "📱"][i]} {zone}
                {selectedZone === i && <span className="ml-auto text-green-500">✓</span>}
              </button>
            ))}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Park scene */}
      <div className="relative overflow-hidden" style={{ height: "600px" }}>
        {/* Background: Sky */}
        <div
          className="absolute inset-0"
          style={{
            background: "linear-gradient(180deg, #B8E8FF 0%, #D4F0C0 45%, #90D060 45%, #70B840 100%)",
          }}
        />

        {/* Clouds */}
        {[
          { cx: 60, cy: 40, r: 22 },
          { cx: 85, cy: 32, r: 16 },
          { cx: 42, cy: 38, r: 14 },
        ].map((c, i) => (
          <motion.div
            key={i}
            className="absolute"
            style={{ left: `${c.cx - c.r}px`, top: `${c.cy - c.r / 2}px` }}
            animate={{ x: [0, 8, 0] }}
            transition={{ duration: 8 + i * 2, repeat: Infinity, ease: "easeInOut" }}
          >
            <svg width={c.r * 3} height={c.r * 1.5} viewBox={`0 0 ${c.r * 3} ${c.r * 1.5}`}>
              <ellipse cx={c.r * 1.5} cy={c.r * 0.9} rx={c.r * 1.5} ry={c.r * 0.6} fill="white" opacity="0.8" />
              <ellipse cx={c.r} cy={c.r * 0.6} rx={c.r} ry={c.r * 0.7} fill="white" opacity="0.8" />
              <ellipse cx={c.r * 2} cy={c.r * 0.7} rx={c.r * 0.9} ry={c.r * 0.6} fill="white" opacity="0.8" />
            </svg>
          </motion.div>
        ))}

        {/* Trees */}
        {[
          { x: 20, y: 215, h: 100, w: 70, color1: "#3A9E48", color2: "#2D8A3B" },
          { x: 240, y: 205, h: 110, w: 80, color1: "#3AAA55", color2: "#2D9A40" },
          { x: 320, y: 220, h: 90, w: 60, color1: "#30883C", color2: "#25703A" },
        ].map((tree, i) => (
          <motion.div
            key={i}
            className="absolute"
            style={{ left: tree.x, top: tree.y }}
            animate={{ rotate: [-1, 1, -1] }}
            transition={{ duration: 4 + i, repeat: Infinity, ease: "easeInOut", delay: i * 0.5 }}
          >
            <svg width={tree.w} height={tree.h} viewBox={`0 0 ${tree.w} ${tree.h}`}>
              <rect x={tree.w / 2 - 5} y={tree.h * 0.6} width="10" height={tree.h * 0.4} fill="#8B4513" />
              <polygon
                points={`${tree.w / 2},0 0,${tree.h * 0.7} ${tree.w},${tree.h * 0.7}`}
                fill={tree.color1}
              />
              <polygon
                points={`${tree.w / 2},${tree.h * 0.2} ${tree.w * 0.1},${tree.h * 0.85} ${tree.w * 0.9},${tree.h * 0.85}`}
                fill={tree.color2}
              />
            </svg>
          </motion.div>
        ))}

        {/* River */}
        <svg
          className="absolute"
          style={{ left: 0, top: 290, width: "100%", height: "60px" }}
          viewBox="0 0 390 60"
          preserveAspectRatio="none"
        >
          <path
            d="M -20 10 Q 80 5 160 15 Q 240 25 330 12 Q 380 6 420 15 L 420 45 Q 380 35 330 40 Q 240 50 160 42 Q 80 35 -20 40 Z"
            fill="#5BB8E8"
            opacity="0.55"
          />
          <motion.path
            d="M 20 22 Q 80 18 140 24 Q 200 30 260 22 Q 320 14 380 22"
            fill="none"
            stroke="white"
            strokeWidth="2"
            opacity="0.4"
            strokeDasharray="8 6"
            animate={{ strokeDashoffset: [0, -28] }}
            transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
          />
        </svg>

        {/* Flowers */}
        {[130, 200, 265, 160, 310].map((x, i) => (
          <motion.div
            key={i}
            className="absolute"
            style={{ left: x, top: 368 + (i % 2) * 8, fontSize: "12px" }}
            animate={{ scale: [1, 1.2, 1], rotate: [0, 10, 0] }}
            transition={{ duration: 2.5, repeat: Infinity, delay: i * 0.4 }}
          >
            {["🌸", "🌼", "🌺", "🌸", "🌼"][i]}
          </motion.div>
        ))}

        {/* Park birds */}
        {parkBirds.map((bird, i) => (
          <motion.button
            key={bird.id}
            className="absolute flex flex-col items-center"
            style={{ left: bird.x, top: bird.y }}
            initial={{ opacity: 0, scale: 0 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.3 + i * 0.15, type: "spring", stiffness: 300 }}
            whileTap={{ scale: 0.9 }}
            onClick={() => setSelectedBird(bird)}
          >
            <motion.div
              animate={{ y: [0, -6, 0] }}
              transition={{
                duration: 2.5 + i * 0.3,
                repeat: Infinity,
                ease: "easeInOut",
                delay: i * 0.4,
              }}
            >
              <PenguinSVG
                color={bird.color}
                accessory={bird.accessory}
                size={58}
              />
            </motion.div>
            <div
              className="mt-1 px-2 py-0.5 rounded-full text-white text-center whitespace-nowrap"
              style={{
                background: "rgba(0,0,0,0.35)",
                backdropFilter: "blur(4px)",
                fontSize: "9px",
              }}
            >
              {bird.name} · {bird.label}
            </div>
          </motion.button>
        ))}

        {/* Wishing tree */}
        <div className="absolute" style={{ right: "12px", bottom: "40px" }}>
          <motion.div
            animate={{ rotate: [-1.5, 1.5, -1.5] }}
            transition={{ duration: 5, repeat: Infinity, ease: "easeInOut" }}
          >
            <svg width="80" height="100" viewBox="0 0 80 100">
              <rect x="35" y="60" width="10" height="35" fill="#8B4513" />
              <circle cx="40" cy="38" r="28" fill="#2ECC71" />
              <circle cx="25" cy="48" r="20" fill="#27AE60" />
              <circle cx="55" cy="48" r="20" fill="#27AE60" />
              <circle cx="40" cy="28" r="18" fill="#33D977" />
              <text x="24" y="20" fontSize="14">🌳</text>
            </svg>
          </motion.div>
          <p
            className="text-center"
            style={{ fontSize: "9px", color: "#3a6a3a", marginTop: "2px" }}
          >
            许愿树
          </p>
          {/* Glowing envelopes */}
          <div className="flex gap-2 justify-center mt-1">
            {[0, 1, 2].map((idx) => (
              <motion.button
                key={idx}
                onClick={() => handleEnvelope(idx)}
                animate={
                  usedEnvelopes.includes(idx)
                    ? { opacity: 0.4 }
                    : {
                        scale: [1, 1.15, 1],
                        filter: [
                          "drop-shadow(0 0 3px rgba(255,220,50,0.6))",
                          "drop-shadow(0 0 8px rgba(255,220,50,0.95))",
                          "drop-shadow(0 0 3px rgba(255,220,50,0.6))",
                        ],
                      }
                }
                transition={{ duration: 1.8, repeat: Infinity, delay: idx * 0.4 }}
                style={{ fontSize: "18px" }}
              >
                💌
              </motion.button>
            ))}
          </div>
        </div>
      </div>

      {/* Toast */}
      <AnimatePresence>
        {showToast && (
          <motion.div
            initial={{ opacity: 0, y: 20, scale: 0.92 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -10, scale: 0.92 }}
            className="fixed z-50 left-1/2 bottom-24 -translate-x-1/2 px-5 py-3 rounded-2xl text-white text-center"
            style={{
              background: "rgba(50,50,80,0.88)",
              backdropFilter: "blur(12px)",
              fontSize: "13px",
              whiteSpace: "nowrap",
            }}
          >
            {toastMsg}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Bird interaction panel */}
      <AnimatePresence>
        {selectedBird && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 z-40 bg-black/30"
              style={{ backdropFilter: "blur(4px)" }}
              onClick={() => setSelectedBird(null)}
            />
            <motion.div
              initial={{ opacity: 0, scale: 0.85, y: 30 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.85, y: 30 }}
              transition={{ type: "spring", stiffness: 400, damping: 30 }}
              className="fixed z-50 left-1/2 -translate-x-1/2 bottom-20 rounded-3xl overflow-hidden"
              style={{
                width: "280px",
                background: "rgba(255,255,255,0.96)",
                boxShadow: "0 20px 60px rgba(0,0,0,0.2)",
              }}
            >
              {/* Header */}
              <div className="px-5 pt-5 pb-4 flex items-center gap-3 border-b border-gray-100">
                <PenguinSVG
                  color={selectedBird.color}
                  accessory={selectedBird.accessory}
                  size={50}
                />
                <div>
                  <p style={{ fontSize: "15px", fontWeight: 700, color: "#2a2a3a" }}>
                    {selectedBird.name}
                  </p>
                  <p style={{ fontSize: "11px", color: "#999", marginTop: "2px" }}>
                    {selectedBird.label} · 积极求职中
                  </p>
                </div>
                <button
                  className="ml-auto"
                  onClick={() => setSelectedBird(null)}
                >
                  <X size={18} color="#ccc" />
                </button>
              </div>

              {/* Action buttons */}
              <div className="p-5">
                <div className="grid grid-cols-3 gap-3">
                  {interactActions.map((action) => (
                    <motion.button
                      key={action.label}
                      whileTap={{ scale: 0.92 }}
                      onClick={() => handleAction(action)}
                      className="flex flex-col items-center gap-2 rounded-2xl py-4"
                      style={{ background: "#F7F7FC" }}
                    >
                      <span style={{ fontSize: "26px" }}>{action.emoji}</span>
                      <span style={{ fontSize: "11px", color: "#666" }}>{action.label}</span>
                    </motion.button>
                  ))}
                </div>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      {/* Envelope encouragement modal */}
      <AnimatePresence>
        {envelopeOpen !== null && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 z-40 bg-black/40"
              style={{ backdropFilter: "blur(6px)" }}
              onClick={() => setEnvelopeOpen(null)}
            />
            <motion.div
              initial={{ opacity: 0, scale: 0.7, rotate: -5 }}
              animate={{ opacity: 1, scale: 1, rotate: 0 }}
              exit={{ opacity: 0, scale: 0.8 }}
              transition={{ type: "spring", stiffness: 350, damping: 25 }}
              className="fixed z-50 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 rounded-3xl p-7 text-center"
              style={{
                width: "290px",
                background: "linear-gradient(135deg, #FFF8E8 0%, #FFF0F8 100%)",
                boxShadow: "0 20px 60px rgba(255,180,50,0.3), 0 0 0 1px rgba(255,200,100,0.3)",
              }}
            >
              <motion.div
                animate={{ scale: [1, 1.15, 1], rotate: [0, 5, 0] }}
                transition={{ duration: 2, repeat: Infinity }}
                style={{ fontSize: "48px", marginBottom: "12px" }}
              >
                💌
              </motion.div>
              <h3 style={{ fontSize: "16px", fontWeight: 700, color: "#8a5a20", marginBottom: "12px" }}>
                ✨ 鼓励信封
              </h3>
              <p
                style={{
                  fontSize: "14px",
                  color: "#6a4a30",
                  lineHeight: "1.8",
                  marginBottom: "20px",
                }}
              >
                {encouragements[envelopeOpen % encouragements.length]}
              </p>
              <motion.button
                whileTap={{ scale: 0.95 }}
                onClick={() => setEnvelopeOpen(null)}
                className="px-8 py-3 rounded-full text-white"
                style={{
                  background: "linear-gradient(135deg, #F5A840, #E8803A)",
                  fontSize: "14px",
                  fontWeight: 600,
                }}
              >
                收下啦 🌟
              </motion.button>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}
