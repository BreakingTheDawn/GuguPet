import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { X, Eye } from "lucide-react";
import bannerBird from "figma:asset/88f44aacb1e776b69b7f57ec3cd974e615f399a3.png";

const columns = [
  {
    id: 1,
    category: "补贴·领取",
    catBg: "#C8F0D4",
    catColor: "#1E6640",
    title: "《毕业补贴完整领取手册》",
    benefits: "包含：7大补贴+申请模板+避坑清单",
    price: "¥9.9",
    emoji: "💰",
    previewContent: [
      "你知道吗？作为应届毕业生，你可能正在错过这些：",
      "📌 求职补贴：大部分省市提供 500-2000 元一次性求职补贴，需在毕业 6 个月内申请。",
      "📌 租房补贴：一线城市及新一线城市对应届生有 1-3 年的租房补贴，每月可领 300-800 元。",
      "📌 技能培训补贴：参加政府认可的职业技能培训，可全额报销或补贴 80%。",
      "…… 本手册还包含社保补贴、创业补贴等共 7 项，附完整申请链接与流程。",
    ],
  },
  {
    id: 2,
    category: "考公·入门",
    catBg: "#C2D9FF",
    catColor: "#1A3E7A",
    title: "《考公小白完全入门手册》",
    benefits: "包含：全流程图解+报名模板+备考计划",
    price: "¥19.9",
    emoji: "📋",
    previewContent: [
      "考公的流程看起来复杂，分步骤来其实并不难——",
      "🗺️ 第一步：搞清楚你要考哪类岗位（国考 / 省考 / 事业单位 / 三支一扶）",
      "🗺️ 第二步：查询报名时间。国考每年 10 月公告，省考多集中在 3-4 月。",
      "🗺️ 第三步：对照职位表筛选适合自己的岗位，重点看「专业」「学历」「政治面貌」三个门槛。",
      "…… 后续章节包含行测备考框架、申论高分模板及 30 天备考计划表。",
    ],
  },
  {
    id: 3,
    category: "简历·优化",
    catBg: "#FFE2CC",
    catColor: "#7A3A10",
    title: "《简历从0到1写作攻略》",
    benefits: "包含：模板×8+HR点评+AI提示词",
    price: "¥14.9",
    emoji: "📝",
    previewContent: [
      "HR 平均看一份简历只用 6 秒，你的简历能通过吗？",
      "✏️ 常见致命错误 #1：工作描述写「负责XXX」——HR 看到这 3 个字直接翻页。",
      "✏️ 正确写法：用「动词 + 数字 + 结果」结构。例：「主导设计 XX 功能，用户转化率提升 23%」。",
      "✏️ 常见致命错误 #2：一份简历投所有岗位——职位描述关键词不匹配，ATS 系统直接过滤。",
      "…… 后续章节包含 8 套分行业模板和 20 条 AI 优化提示词，可直接套用。",
    ],
  },
  {
    id: 4,
    category: "面试·技巧",
    catBg: "#E8D4FF",
    catColor: "#4A1A7A",
    title: "《高频面试题答题框架》",
    benefits: "包含：50题+STAR模板+反问清单",
    price: "¥19.9",
    emoji: "🎯",
    previewContent: [
      "「你能介绍一下自己吗？」这题99%的人都没答好。",
      "🔑 黄金公式：30秒背景 + 30秒亮点经历 + 10秒与岗位的连接。",
      "🔑 背景：「我是XX大学XX专业的应届毕业生，主要学习方向是……」",
      "🔑 亮点经历：「在校期间，我做了一个让我印象最深的项目……（用数字证明价值）」",
      "🔑 连接岗位：「这段经历让我觉得自己非常适合贵司这个职位，因为……」",
      "…… 后续包含「为什么跳槽」「你的缺点是什么」等 50 道高频题完整答题示范。",
    ],
  },
  {
    id: 5,
    category: "职场·避坑",
    catBg: "#FFF0C0",
    catColor: "#6A4A00",
    title: "《职场新人第一年避坑手册》",
    benefits: "包含：20个坑+话术模板+晋升地图",
    price: "¥14.9",
    emoji: "🗺️",
    previewContent: [
      "90% 的职场新人都踩过这些坑，你中了几个？",
      "⚠️ 坑 #1：把「努力工作」等同于「表现好」。努力不等于价值可见，你需要主动汇报进度。",
      "⚠️ 坑 #2：不懂「向上管理」。让领导知道你在做什么，比做了什么更重要。",
      "⚠️ 坑 #3：第一个月就提涨薪。试用期内提薪会让你的职业生涯直接终结于这家公司。",
      "…… 本手册共 20 个实战避坑经验，附带每个场景的话术模板，可直接复用。",
    ],
  },
  {
    id: 6,
    category: "选城·落户",
    catBg: "#C8F0F8",
    catColor: "#0A4A5A",
    title: "《新一线城市落户完全攻略》",
    benefits: "包含：12城对比+积分模拟+时间轴",
    price: "¥12.9",
    emoji: "🏙️",
    previewContent: [
      "留北上广还是去新一线？这份数据对比或许能帮你决定。",
      "📊 落户门槛对比（应届生专项）：",
      "成都：本科直接落户，无需积分，到场办理一天完成。",
      "杭州：本科落户限额制，每年约 3 万名额，先到先得。",
      "武汉：本科+40周岁以下可直接落户，还有额外购房补贴。",
      "…… 本手册覆盖成都、杭州、武汉、南京等 12 座城市，附带落户积分模拟计算器。",
    ],
  },
  {
    id: 7,
    category: "薪资·谈判",
    catBg: "#FFD4E4",
    catColor: "#7A1A3A",
    title: "《薪资谈判完全指南》",
    benefits: "包含：话术脚本+常见陷阱+期望报价公式",
    price: "¥9.9",
    emoji: "💼",
    previewContent: [
      "「你期望薪资是多少？」这一句话，可能值几万元。",
      "💡 核心策略：永远不要第一个报数。先反问「这个岗位的薪资范围是多少？」",
      "💡 如果对方坚持让你先报：用「期望区间」代替「精确数字」，给自己留余地。",
      "💡 公式：目标薪资 = 当前市场水平 × 1.15 ~ 1.25（跳槽溢价）",
      "…… 本指南包含完整对话脚本、7 种常见谈判陷阱识别，以及如何利用 Offer 竞价拉高薪资。",
    ],
  },
  {
    id: 8,
    category: "实习·转正",
    catBg: "#D4F0C0",
    catColor: "#1A5A2A",
    title: "《实习生转正成功率提升手册》",
    benefits: "包含：转正评估表+关键节点清单+案例库",
    price: "¥12.9",
    emoji: "🌱",
    previewContent: [
      "从实习到转正，决定结果的往往是这 3 件事——",
      "🌱 关键因素 #1：第 3 天的「期望对齐会」。主动找导师 1v1，搞清楚「转正的评判标准是什么」。",
      "🌱 关键因素 #2：第 30 天的「成果可视化」。整理一份自己的阶段成果文档，主动发给导师。",
      "🌱 关键因素 #3：第 60 天的「人际网络建立」。在组内至少与 5 位核心成员建立实质性合作关系。",
      "…… 本手册包含完整转正评估模板、每周关键节点 Checklist，以及 10 个真实转正/未转正案例分析。",
    ],
  },
];

// ─── Preview Modal ─────────────────────────────────────────
function PreviewModal({
  column,
  onClose,
}: {
  column: (typeof columns)[0] | null;
  onClose: () => void;
}) {
  return (
    <AnimatePresence>
      {column && (
        <>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-40 bg-black/45"
            style={{ backdropFilter: "blur(6px)" }}
            onClick={onClose}
          />
          <motion.div
            initial={{ opacity: 0, y: "100%" }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: "100%" }}
            transition={{ type: "spring", stiffness: 380, damping: 36 }}
            className="fixed z-50 left-0 right-0 bottom-0 rounded-t-3xl overflow-hidden"
            style={{
              maxHeight: "72%",
              background: "#FDFAF4",
            }}
          >
            {/* Drag handle */}
            <div className="flex justify-center pt-3 pb-1">
              <div className="w-10 h-1 rounded-full bg-gray-200" />
            </div>

            {/* Header */}
            <div
              className="flex items-start justify-between px-5 py-3 border-b"
              style={{ borderColor: "rgba(160,120,60,0.15)" }}
            >
              <div className="flex-1 pr-4">
                <div
                  className="inline-flex items-center rounded-full px-3 py-0.5 mb-2"
                  style={{ background: column.catBg, fontSize: "10px", color: column.catColor, fontWeight: 600 }}
                >
                  {column.category}
                </div>
                <h3 style={{ fontSize: "15px", fontWeight: 700, color: "#2a1a0a", lineHeight: 1.4 }}>
                  {column.title}
                </h3>
                <p style={{ fontSize: "11px", color: "#A08050", marginTop: "4px" }}>
                  前 20% 内容免费预览
                </p>
              </div>
              <button onClick={onClose} className="mt-1">
                <X size={20} color="#C0A880" />
              </button>
            </div>

            {/* Content */}
            <div className="px-5 py-4 overflow-y-auto" style={{ maxHeight: "380px" }}>
              <div className="space-y-3">
                {column.previewContent.map((line, i) => (
                  <motion.p
                    key={i}
                    initial={{ opacity: 0, x: -8 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: i * 0.06 }}
                    style={{
                      fontSize: "13px",
                      color: "#4a3a2a",
                      lineHeight: "1.8",
                    }}
                  >
                    {line}
                  </motion.p>
                ))}
              </div>

              {/* Fade-out blur effect */}
              <div
                className="pointer-events-none"
                style={{
                  height: "60px",
                  background: "linear-gradient(to bottom, transparent, #FDFAF4)",
                  marginTop: "-20px",
                  position: "relative",
                  zIndex: 2,
                }}
              />
            </div>

            {/* Unlock CTA */}
            <div className="px-5 pb-6">
              <motion.button
                whileTap={{ scale: 0.97 }}
                className="w-full py-4 rounded-2xl text-white relative overflow-hidden"
                style={{
                  background: "linear-gradient(135deg, #8B6040 0%, #6A4020 100%)",
                  fontSize: "15px",
                  fontWeight: 700,
                }}
              >
                <span>解锁完整内容 · {column.price}</span>
                {/* Shimmer */}
                <motion.div
                  className="absolute top-0 bottom-0 w-16 pointer-events-none"
                  style={{
                    background:
                      "linear-gradient(90deg, transparent, rgba(255,255,255,0.22), transparent)",
                    filter: "blur(4px)",
                  }}
                  animate={{ x: ["-80px", "420px"] }}
                  transition={{ duration: 2.5, repeat: Infinity, ease: "linear", repeatDelay: 1.5 }}
                />
              </motion.button>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}

// ─── Column Card ────────────────────────────────────────────
function ColumnCard({
  column,
  index,
  onPreview,
}: {
  column: (typeof columns)[0];
  index: number;
  onPreview: (col: (typeof columns)[0]) => void;
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20, scale: 0.96 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      transition={{ delay: index * 0.07, type: "spring", stiffness: 280, damping: 26 }}
      className="relative rounded-2xl overflow-hidden flex flex-col"
      style={{
        background: "linear-gradient(145deg, #EDD8A8 0%, #E3C47E 100%)",
        boxShadow:
          "0 4px 16px rgba(100,70,20,0.15), 0 1px 0 rgba(255,255,255,0.4) inset",
        border: "1px solid rgba(180,130,60,0.22)",
        minHeight: "170px",
      }}
    >
      {/* Kraft texture strip on left */}
      <div
        className="absolute left-0 top-0 bottom-0 w-2 rounded-l-2xl"
        style={{ background: "rgba(120,80,20,0.12)" }}
      />

      {/* Fold corner - top right */}
      <div
        className="absolute top-0 right-0"
        style={{
          width: 0,
          height: 0,
          borderStyle: "solid",
          borderWidth: "0 18px 18px 0",
          borderColor: "transparent rgba(120,80,20,0.18) transparent transparent",
        }}
      />
      <div
        className="absolute"
        style={{
          top: "1px",
          right: "1px",
          width: "14px",
          height: "14px",
          background: "linear-gradient(135deg, #D4A860 50%, transparent 50%)",
          borderBottomLeftRadius: "6px",
        }}
      />

      {/* Card content */}
      <div className="flex-1 p-3 pl-4">
        {/* Category tag */}
        <div className="flex items-center justify-between mb-2">
          <span
            className="rounded-full px-2.5 py-0.5"
            style={{
              background: column.catBg,
              color: column.catColor,
              fontSize: "9px",
              fontWeight: 700,
              letterSpacing: "0.03em",
            }}
          >
            {column.category}
          </span>
          <span style={{ fontSize: "16px" }}>{column.emoji}</span>
        </div>

        {/* Title */}
        <p
          style={{
            fontSize: "12px",
            fontWeight: 700,
            color: "#2A1A08",
            lineHeight: "1.5",
            marginBottom: "5px",
          }}
        >
          {column.title}
        </p>

        {/* Benefits hook */}
        <p
          style={{
            fontSize: "9.5px",
            color: "#8A6A40",
            lineHeight: "1.5",
          }}
        >
          {column.benefits}
        </p>
      </div>

      {/* Bottom bar */}
      <div
        className="flex items-center justify-between px-4 pl-4 py-2.5"
        style={{
          background: "rgba(120,80,20,0.07)",
          borderTop: "1px solid rgba(120,80,20,0.1)",
        }}
      >
        {/* Try reading button */}
        <motion.button
          whileTap={{ scale: 0.92 }}
          onClick={() => onPreview(column)}
          className="flex items-center gap-1 rounded-full px-2.5 py-1"
          style={{
            background: "rgba(255,255,255,0.55)",
            border: "1px solid rgba(120,80,20,0.2)",
          }}
        >
          <Eye size={10} color="#8A6A40" />
          <span style={{ fontSize: "9px", color: "#8A6A40", fontWeight: 600 }}>
            试读
          </span>
        </motion.button>

        {/* Price */}
        <span
          style={{
            fontSize: "13px",
            fontWeight: 700,
            color: "#3A2A18",
          }}
        >
          {column.price}
        </span>
      </div>
    </motion.div>
  );
}

// ─── Bottom CTA Button ──────────────────────────────────────
function BottomCTA() {
  const [tapped, setTapped] = useState(false);

  return (
    <div
      className="sticky bottom-0 px-4 pb-4 pt-3"
      style={{
        background: "linear-gradient(to top, #F7F4EF 60%, transparent)",
        pointerEvents: "none",
      }}
    >
      <motion.button
        whileTap={{ scale: 0.97 }}
        onTap={() => {
          setTapped(true);
          setTimeout(() => setTapped(false), 600);
        }}
        className="w-full py-4 rounded-full relative overflow-hidden"
        style={{
          background: "linear-gradient(135deg, #7A5030 0%, #5A3318 100%)",
          boxShadow: "0 8px 28px rgba(90,50,24,0.4), 0 2px 8px rgba(90,50,24,0.2)",
          pointerEvents: "auto",
        }}
      >
        {/* Shimmer sweep */}
        <motion.div
          className="absolute top-0 bottom-0 w-24 pointer-events-none"
          style={{
            background:
              "linear-gradient(90deg, transparent, rgba(255,240,210,0.28), transparent)",
            filter: "blur(6px)",
          }}
          animate={{ x: ["-100px", "480px"] }}
          transition={{ duration: 2.8, repeat: Infinity, ease: "linear", repeatDelay: 1.2 }}
        />

        <div className="relative flex items-center justify-center gap-2">
          <span style={{ fontSize: "20px" }}>📦</span>
          <div className="text-left">
            <p style={{ fontSize: "14px", fontWeight: 700, color: "white", lineHeight: 1.2 }}>
              一键带走全套档案馆
            </p>
            <p style={{ fontSize: "11px", color: "rgba(255,220,180,0.85)", marginTop: "1px" }}>
              8册合集 · 原价 ¥123.2 · 现仅 ¥49.9
            </p>
          </div>
          <motion.div
            animate={tapped ? { scale: [1, 1.4, 1], rotate: [0, 15, 0] } : {}}
            style={{ fontSize: "18px", marginLeft: "4px" }}
          >
            ✨
          </motion.div>
        </div>
      </motion.button>
    </div>
  );
}

// ─── Main Screen ────────────────────────────────────────────
export function KnowledgeScreen() {
  const [previewColumn, setPreviewColumn] = useState<(typeof columns)[0] | null>(null);

  return (
    <div style={{ background: "#F7F4EF", minHeight: "100%" }}>
      {/* Hero Banner */}
      <div
        className="relative overflow-hidden"
        style={{ height: "188px" }}
      >
        {/* Bird image – dimmed background */}
        <motion.img
          src={bannerBird}
          alt="咕咕鸟"
          initial={{ opacity: 0, scale: 1.05 }}
          animate={{ opacity: 0.22, scale: 1 }}
          transition={{ duration: 0.8 }}
          className="absolute"
          style={{
            right: "-10px",
            bottom: "-10px",
            height: "200px",
            width: "auto",
            objectFit: "contain",
          }}
        />

        {/* Warm gradient overlay */}
        <div
          className="absolute inset-0"
          style={{
            background:
              "linear-gradient(135deg, #5A3318 0%, #8B5A2A 50%, rgba(139,90,42,0.7) 100%)",
          }}
        />

        {/* Decorative dots */}
        {[...Array(12)].map((_, i) => (
          <motion.div
            key={i}
            className="absolute rounded-full"
            style={{
              width: `${4 + (i % 3) * 2}px`,
              height: `${4 + (i % 3) * 2}px`,
              background: "rgba(255,220,160,0.2)",
              left: `${8 + (i * 27) % 82}%`,
              top: `${10 + (i * 19) % 70}%`,
            }}
            animate={{ opacity: [0.2, 0.6, 0.2], scale: [0.9, 1.2, 0.9] }}
            transition={{ duration: 3 + i * 0.4, repeat: Infinity, delay: i * 0.3 }}
          />
        ))}

        {/* Text content */}
        <div className="absolute inset-0 flex flex-col justify-end px-5 pb-5">
          <motion.div
            initial={{ opacity: 0, y: 14 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.25 }}
          >
            <div
              className="inline-flex items-center gap-1.5 rounded-full px-3 py-1 mb-2"
              style={{
                background: "rgba(255,220,160,0.2)",
                border: "1px solid rgba(255,220,160,0.3)",
              }}
            >
              <span style={{ fontSize: "10px" }}>🎓</span>
              <span style={{ fontSize: "10px", color: "rgba(255,220,160,0.9)", fontWeight: 600 }}>
                咕咕精选 · 毕业特辑
              </span>
            </div>
            <h1
              style={{
                fontSize: "18px",
                fontWeight: 800,
                color: "white",
                lineHeight: 1.35,
                letterSpacing: "0.01em",
              }}
            >
              毕业不迷茫：
              <br />
              咕咕的避坑档案馆
            </h1>
            <p style={{ fontSize: "11px", color: "rgba(255,220,160,0.8)", marginTop: "6px" }}>
              8 份干货手册 · 陪你迈过每道坎
            </p>
          </motion.div>
        </div>
      </div>

      {/* Section header */}
      <div className="flex items-center justify-between px-4 pt-4 pb-3">
        <div>
          <h2 style={{ fontSize: "15px", fontWeight: 700, color: "#2A1A08" }}>
            全套档案馆
          </h2>
          <p style={{ fontSize: "11px", color: "#A08050", marginTop: "1px" }}>
            共 {columns.length} 份专栏 · 持续更新中
          </p>
        </div>
        <div
          className="rounded-full px-3 py-1.5"
          style={{ background: "#EDD8A8", fontSize: "11px", color: "#7A5030", fontWeight: 600 }}
        >
          🗂️ 档案馆
        </div>
      </div>

      {/* Category filter pills */}
      <div
        className="flex gap-2 px-4 pb-3 overflow-x-auto"
        style={{ scrollbarWidth: "none" }}
      >
        {["全部", "求职技能", "政策补贴", "职场成长", "考公备考"].map((cat, i) => (
          <motion.button
            key={cat}
            initial={{ opacity: 0, x: -6 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: i * 0.05 }}
            className="rounded-full px-4 py-1.5 whitespace-nowrap flex-shrink-0"
            style={{
              background: i === 0 ? "#8B5A2A" : "rgba(180,130,60,0.12)",
              color: i === 0 ? "white" : "#8A6A40",
              fontSize: "11px",
              fontWeight: i === 0 ? 600 : 400,
            }}
          >
            {cat}
          </motion.button>
        ))}
      </div>

      {/* Double column card grid */}
      <div className="grid grid-cols-2 gap-3 px-4 pb-4">
        {columns.map((col, i) => (
          <ColumnCard key={col.id} column={col} index={i} onPreview={setPreviewColumn} />
        ))}
      </div>

      {/* Bottom CTA */}
      <BottomCTA />

      {/* Preview modal */}
      <PreviewModal column={previewColumn} onClose={() => setPreviewColumn(null)} />
    </div>
  );
}
