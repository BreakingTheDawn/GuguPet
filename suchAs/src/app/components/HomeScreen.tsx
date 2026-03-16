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
      className="relative w-full h-full flex flex-col"
      style={{
        minHeight: "100%",
        background: "linear-gradient(175deg, #FFF8EF 0%, #EEF2FF 45%, #F0EBFF 100%)",
      }}
    >
      {/* Top bar */}
      <div className="flex items-center justify-between px-6 pt-10 pb-2">
        <div className="w-full text-center">
          <motion.p
            initial={{ opacity: 0, y: -8 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="text-gray-400 tracking-[0.2em]"
            style={{ fontSize: "12px" }}
          >
            职宠小窝
          </motion.p>
        </div>
      </div>

      {/* Decorative stars */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        {[
          { left: "12%", top: "15%", delay: 0 },
          { left: "82%", top: "12%", delay: 0.5 },
          { left: "88%", top: "35%", delay: 1 },
          { left: "8%", top: "40%", delay: 1.5 },
          { left: "92%", top: "55%", delay: 0.8 },
          { left: "5%", top: "60%", delay: 1.2 },
        ].map((star, i) => (
          <motion.div
            key={i}
            className="absolute text-indigo-200"
            style={{ left: star.left, top: star.top, fontSize: "10px" }}
            animate={{ opacity: [0.3, 0.9, 0.3], scale: [0.8, 1.2, 0.8] }}
            transition={{ duration: 3, repeat: Infinity, delay: star.delay }}
          >
            ✦
          </motion.div>
        ))}
      </div>

      {/* Main content area */}
      <div
        className="flex-1 flex flex-col items-center justify-center relative"
        style={{ paddingBottom: "20px" }}
      >
        {/* Response bubble */}
        <AnimatePresence>
          {showResponse && (
            <motion.div
              initial={{ opacity: 0, scale: 0.85, y: 12 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: -8 }}
              transition={{ type: "spring", stiffness: 400, damping: 28 }}
              className="mb-5 px-5 py-4 rounded-3xl text-center"
              style={{
                background: "rgba(255,255,255,0.82)",
                backdropFilter: "blur(16px)",
                border: "1px solid rgba(255,255,255,0.9)",
                boxShadow: "0 8px 32px rgba(100,80,200,0.1)",
                maxWidth: "280px",
                fontSize: "14px",
                color: "#5a5a7a",
                lineHeight: "1.7",
              }}
            >
              {response}
            </motion.div>
          )}
        </AnimatePresence>

        {/* Bird + bubble */}
        <div className="relative flex items-start">
          {/* Bird image with animation */}
          <motion.div
            animate={
              isHappy
                ? {
                    y: [0, -22, -8, -18, 0],
                    rotate: [-2, 3, -3, 2, 0],
                  }
                : {
                    y: [0, -10, 0],
                    rotate: [-1.5, 1.5, -1.5],
                  }
            }
            transition={
              isHappy
                ? { duration: 1.8, ease: "easeInOut" }
                : { duration: 3.5, repeat: Infinity, ease: "easeInOut" }
            }
            style={{ filter: "drop-shadow(0 12px 28px rgba(100,80,200,0.18))" }}
          >
            <img
              src={birdImg}
              alt="咕咕鸟"
              style={{ width: "210px", height: "auto" }}
            />
          </motion.div>

          {/* Side bubble */}
          <motion.div
            animate={{ scale: [1, 1.08, 1], rotate: [-3, 3, -3] }}
            transition={{ duration: 2.2, repeat: Infinity, ease: "easeInOut" }}
            className="absolute flex items-center justify-center rounded-2xl"
            style={{
              right: "-18px",
              top: "28px",
              width: "44px",
              height: "44px",
              background: "rgba(255,255,255,0.75)",
              backdropFilter: "blur(12px)",
              border: "1.5px solid rgba(255,255,255,0.95)",
              boxShadow: "0 4px 16px rgba(100,80,200,0.15)",
              fontSize: "20px",
            }}
          >
            {isHappy ? "🥰" : "🫂"}
          </motion.div>
        </div>

        {/* Subtle waiting hint */}
        <AnimatePresence mode="wait">
          {!showResponse && (
            <motion.p
              key="hint"
              initial={{ opacity: 0, y: 6 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -4 }}
              transition={{ delay: 0.4 }}
              className="mt-4 text-center"
              style={{ fontSize: "12px", color: "#bbb0d0" }}
            >
              {messageCount === 0 ? "咕咕在等你倾诉..." : `已倾诉 ${messageCount} 次，咕咕一直在 ♡`}
            </motion.p>
          )}
        </AnimatePresence>
      </div>

      {/* Input area */}
      <div className="px-5 pb-5">
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6 }}
          className="text-center mb-2"
          style={{ fontSize: "12px", color: "#b8b0d0", letterSpacing: "0.05em" }}
        >
          此刻想对咕咕说点什么？
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.7, type: "spring", stiffness: 300 }}
          className="flex items-center gap-3 rounded-3xl px-5 py-4"
          style={{
            background: "rgba(255,255,255,0.65)",
            backdropFilter: "blur(24px)",
            border: "1.5px solid rgba(255,255,255,0.88)",
            boxShadow: "0 8px 32px rgba(100,80,200,0.1), 0 2px 8px rgba(0,0,0,0.05)",
          }}
        >
          <input
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && handleSubmit()}
            placeholder="今天又投了5份简历，有点累了..."
            className="flex-1 bg-transparent outline-none"
            style={{
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
                className="flex-shrink-0"
                style={{ fontSize: "20px" }}
                whileTap={{ scale: 0.85 }}
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
