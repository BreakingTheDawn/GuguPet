import { useState, useRef } from "react";
import { motion, AnimatePresence } from "motion/react";
import birdImg from "figma:asset/0cc679ce443880c7f323ac5b0b65175c8b133bd3.png";

const RESPONSES: { pattern: RegExp; text: string }[] = [
  { pattern: /累|疲|倦|撑|崩|烦|难|苦|压力/, text: "累了就歇歇，你已经很努力了 🤍 轻轻抱抱你~" },
  { pattern: /面试|hr|HR|笔试|offer|Offer|OFFER/, text: "面试官看到你一定会心动的！咕咕为你加油 ✨" },
  { pattern: /拒|没过|挂|凉|凉凉|拒绝|失败/, text: "他们眼光有问题！你是最棒的，咕咕最喜欢你 🫂" },
  { pattern: /开心|高兴|棒|好消息|发|拿到|通过|过了/, text: "太好了！咕咕也为你感到超级开心~ 🎉🎊" },
  { pattern: /不知道|迷茫|迷失|找不到|方向/, text: "迷茫也没关系，每一步都算数的，我一直陪着你 🌟" },
];
const DEFAULT_RESPONSES = [
  "嗯嗯，我都听到了，说出来感觉好一点了吗？ 🐧",
  "你已经很棒了，不管怎样咕咕都支持你 ✨",
  "今天的委屈，明天变成铠甲，加油！",
  "咕咕在这里，轻轻抱抱你 🤍",
];

function getResponse(text: string): string {
  for (const { pattern, text: resp } of RESPONSES) {
    if (pattern.test(text)) return resp;
  }
  return DEFAULT_RESPONSES[Math.floor(Math.random() * DEFAULT_RESPONSES.length)];
}

export function HomeScreen() {
  const [input, setInput] = useState("");
  const [response, setResponse] = useState("");
  const [showResponse, setShowResponse] = useState(false);
  const [isHappy, setIsHappy] = useState(false);
  const [messageCount, setMessageCount] = useState(0);
  const timeoutRef = useRef<number>();

  const handleSubmit = () => {
    if (!input.trim()) return;
    const resp = getResponse(input);
    setResponse(resp);
    setShowResponse(true);
    setIsHappy(true);
    setMessageCount((c) => c + 1);
    setInput("");
    if (timeoutRef.current) clearTimeout(timeoutRef.current);
    timeoutRef.current = window.setTimeout(() => {
      setShowResponse(false);
      setIsHappy(false);
    }, 5500);
  };

  return (
    <div
      className="relative flex flex-col"
      style={{
        minHeight: "100%",
        background: "linear-gradient(175deg, #FFF8EF 0%, #EEF2FF 48%, #F0EBFF 100%)",
      }}
    >
      {/* Decorative floating stars */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        {[
          { left: "10%", top: "8%", delay: 0, size: 8 },
          { left: "84%", top: "6%", delay: 0.6, size: 6 },
          { left: "90%", top: "28%", delay: 1.1, size: 8 },
          { left: "6%", top: "35%", delay: 1.7, size: 6 },
          { left: "88%", top: "52%", delay: 0.9, size: 7 },
          { left: "4%", top: "60%", delay: 1.4, size: 6 },
        ].map((star, i) => (
          <motion.div
            key={i}
            className="absolute"
            style={{
              left: star.left,
              top: star.top,
              fontSize: `${star.size}px`,
              color: "#c8b8e8",
            }}
            animate={{ opacity: [0.25, 0.85, 0.25], scale: [0.8, 1.3, 0.8] }}
            transition={{ duration: 3.5, repeat: Infinity, delay: star.delay }}
          >
            ✦
          </motion.div>
        ))}
      </div>

      {/* Main content area */}
      <div className="flex-1 flex flex-col items-center justify-center relative" style={{ paddingBottom: "16px" }}>
        {/* Response bubble */}
        <AnimatePresence>
          {showResponse && (
            <motion.div
              initial={{ opacity: 0, scale: 0.82, y: 14 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: -8 }}
              transition={{ type: "spring", stiffness: 420, damping: 30 }}
              className="mb-5 px-5 py-4 rounded-3xl text-center"
              style={{
                background: "rgba(255,255,255,0.85)",
                backdropFilter: "blur(18px)",
                border: "1.5px solid rgba(255,255,255,0.95)",
                boxShadow: "0 8px 32px rgba(100,80,200,0.12)",
                maxWidth: "282px",
                fontSize: "14px",
                color: "#5a5a7a",
                lineHeight: "1.75",
              }}
            >
              {response}
            </motion.div>
          )}
        </AnimatePresence>

        {/* ── Pseudo-3D Bird ── */}
        <div className="relative flex items-start" style={{ perspective: "700px" }}>
          {/* Ground shadow */}
          <motion.div
            animate={
              isHappy
                ? { scaleX: [1, 1.3, 0.75, 1.1, 1], opacity: [0.45, 0.55, 0.2, 0.45, 0.45], x: [0, 12, -10, 6, 0] }
                : { scaleX: [0.95, 0.62, 0.95], opacity: [0.4, 0.18, 0.4], x: [-8, 8, -8] }
            }
            transition={
              isHappy
                ? { duration: 1.8, ease: "easeInOut" }
                : { duration: 4, repeat: Infinity, ease: "easeInOut" }
            }
            style={{
              position: "absolute",
              bottom: "-14px",
              left: "50%",
              translateX: "-50%",
              width: "130px",
              height: "18px",
              borderRadius: "50%",
              background: "rgba(100,80,160,0.14)",
              filter: "blur(9px)",
            }}
          />

          {/* 3D Bird */}
          <motion.div
            animate={
              isHappy
                ? {
                    y: [0, -26, -10, -20, 0],
                    rotateY: [0, 22, -16, 12, 0],
                    rotateX: [-2, 6, -5, 4, 0],
                    filter: [
                      "brightness(1) drop-shadow(0 18px 28px rgba(100,80,200,0.18))",
                      "brightness(1.1) drop-shadow(10px 14px 28px rgba(100,80,200,0.1))",
                      "brightness(0.93) drop-shadow(-10px 20px 32px rgba(100,80,200,0.24))",
                      "brightness(1.06) drop-shadow(6px 14px 22px rgba(100,80,200,0.14))",
                      "brightness(1) drop-shadow(0 18px 28px rgba(100,80,200,0.18))",
                    ],
                  }
                : {
                    y: [0, -10, 0],
                    rotateY: [-13, 13, -13],
                    rotateX: [5, -5, 5],
                    filter: [
                      "brightness(0.96) drop-shadow(-5px 18px 28px rgba(100,80,200,0.22))",
                      "brightness(1.05) drop-shadow(5px 18px 28px rgba(100,80,200,0.14))",
                      "brightness(0.96) drop-shadow(-5px 18px 28px rgba(100,80,200,0.22))",
                    ],
                  }
            }
            transition={
              isHappy
                ? { duration: 1.8, ease: "easeInOut" }
                : { duration: 4, repeat: Infinity, ease: "easeInOut" }
            }
            style={{ transformStyle: "preserve-3d" }}
          >
            <img
              src={birdImg}
              alt="咕咕鸟"
              style={{ width: "215px", height: "auto", display: "block" }}
            />
          </motion.div>

          {/* Floating side bubble */}
          <motion.div
            animate={{ scale: [1, 1.09, 1], rotate: [-4, 4, -4] }}
            transition={{ duration: 2.4, repeat: Infinity, ease: "easeInOut" }}
            style={{
              position: "absolute",
              right: "-20px",
              top: "30px",
              width: "46px",
              height: "46px",
              borderRadius: "50%",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: "20px",
              background: "rgba(255,255,255,0.78)",
              backdropFilter: "blur(12px)",
              border: "1.5px solid rgba(255,255,255,0.95)",
              boxShadow: "0 4px 18px rgba(100,80,200,0.16)",
            }}
          >
            {isHappy ? "🥰" : "🫂"}
          </motion.div>
        </div>

        {/* Hint text */}
        <AnimatePresence mode="wait">
          {!showResponse && (
            <motion.p
              key="hint"
              initial={{ opacity: 0, y: 6 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -4 }}
              transition={{ delay: 0.3 }}
              style={{
                marginTop: "22px",
                fontSize: "12px",
                color: "#c8b8e0",
                textAlign: "center",
              }}
            >
              {messageCount === 0 ? "咕咕在等你倾诉..." : `已倾诉 ${messageCount} 次，咕咕一直在 ♡`}
            </motion.p>
          )}
        </AnimatePresence>
      </div>

      {/* Input area */}
      <div style={{ padding: "0 18px 20px" }}>
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
          style={{
            textAlign: "center",
            marginBottom: "8px",
            fontSize: "11px",
            color: "#c0b0d8",
            letterSpacing: "0.05em",
          }}
        >
          此刻想对咕咕说点什么？
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.65, type: "spring", stiffness: 280 }}
          style={{
            display: "flex",
            alignItems: "center",
            gap: "12px",
            borderRadius: "28px",
            padding: "14px 20px",
            background: "rgba(255,255,255,0.66)",
            backdropFilter: "blur(24px)",
            border: "1.5px solid rgba(255,255,255,0.9)",
            boxShadow: "0 8px 32px rgba(100,80,200,0.1), 0 2px 8px rgba(0,0,0,0.05)",
          }}
        >
          <input
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && handleSubmit()}
            placeholder="今天又投了5份简历，有点累了..."
            style={{
              flex: 1,
              background: "transparent",
              outline: "none",
              border: "none",
              color: "#5a5a7a",
              fontSize: "14px",
            }}
          />
          <AnimatePresence>
            {input.trim() && (
              <motion.button
                initial={{ scale: 0, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                exit={{ scale: 0, opacity: 0 }}
                onClick={handleSubmit}
                style={{ fontSize: "22px", flexShrink: 0 }}
                whileTap={{ scale: 0.82 }}
              >
                🕊️
              </motion.button>
            )}
          </AnimatePresence>
        </motion.div>
      </div>
    </div>
  );
}
