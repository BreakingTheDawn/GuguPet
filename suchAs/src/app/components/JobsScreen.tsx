import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { X, Search, SlidersHorizontal, MapPin, Clock, Star } from "lucide-react";
import birdImg from "figma:asset/0cc679ce443880c7f323ac5b0b65175c8b133bd3.png";

const jobs = [
  {
    id: 1,
    title: "UI设计师",
    salary: "15k-20k",
    company: "某创意科技有限公司",
    location: "上海·静安区",
    tags: ["双休", "五险一金", "扁平管理"],
    isNew: true,
    isUrgent: false,
    salaryColor: "#E8805A",
    posted: "1小时前",
    desc: "负责公司核心产品的视觉设计，包括移动端App、Web端界面设计，参与品牌视觉规范制定。要求3年以上UI设计经验，熟练使用Figma。",
  },
  {
    id: 2,
    title: "产品经理",
    salary: "18k-25k",
    company: "某知名互联网大厂",
    location: "北京·朝阳区",
    tags: ["六险一金", "期权激励", "免费三餐"],
    isNew: false,
    isUrgent: true,
    salaryColor: "#5A8AE8",
    posted: "3小时前",
    desc: "主导2C产品从0到1的设计规划，深入分析用户需求，驱动产品功能迭代优化。需要有完整的产品生命周期管理经验。",
  },
  {
    id: 3,
    title: "前端工程师",
    salary: "20k-30k",
    company: "某头部电商平台",
    location: "杭州·余杭区",
    tags: ["双休", "五险一金", "弹性工作"],
    isNew: true,
    isUrgent: false,
    salaryColor: "#5ABE8A",
    posted: "5小时前",
    desc: "负责核心业务前端研发，技术栈React/TypeScript，参与架构设计，推动团队工程化建设。3年以上前端开发经验。",
  },
  {
    id: 4,
    title: "品牌运营专员",
    salary: "8k-12k",
    company: "某新消费品牌",
    location: "广州·天河区",
    tags: ["双休", "五险一金", "餐补"],
    isNew: false,
    isUrgent: false,
    salaryColor: "#C87ACA",
    posted: "昨天",
    desc: "负责品牌社媒运营，包括小红书、微博、微信公众号等平台内容策划与发布，数据分析和优化。",
  },
  {
    id: 5,
    title: "数据分析师",
    salary: "15k-22k",
    company: "某头部本地生活平台",
    location: "北京·海淀区",
    tags: ["双休", "年终奖", "补充医疗"],
    isNew: false,
    isUrgent: true,
    salaryColor: "#E8C03A",
    posted: "昨天",
    desc: "负责业务数据的统计分析，搭建数据指标体系，输出数据报告，为业务决策提供数据支持。",
  },
];

function JobCard({ job, index }: { job: (typeof jobs)[0]; index: number }) {
  const [showDetail, setShowDetail] = useState(false);

  return (
    <>
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: index * 0.08, type: "spring", stiffness: 280, damping: 28 }}
        className="mx-4 rounded-3xl p-5 relative overflow-hidden"
        style={{
          background: "white",
          boxShadow: "0 4px 20px rgba(0,0,0,0.07)",
        }}
      >
        {/* Badges */}
        <div className="absolute top-4 right-4 flex gap-1.5">
          {job.isNew && (
            <span
              className="rounded-full px-2 py-0.5 text-white"
              style={{ background: "#5ABE8A", fontSize: "9px", fontWeight: 600 }}
            >
              NEW
            </span>
          )}
          {job.isUrgent && (
            <span
              className="rounded-full px-2 py-0.5 text-white"
              style={{ background: "#E8605A", fontSize: "9px", fontWeight: 600 }}
            >
              急招
            </span>
          )}
        </div>

        {/* Title + salary */}
        <div className="flex items-start justify-between pr-12">
          <h3 style={{ fontSize: "18px", fontWeight: 700, color: "#1a1a2e" }}>
            {job.title}
          </h3>
        </div>
        <p style={{ fontSize: "16px", fontWeight: 700, color: job.salaryColor, marginTop: "4px" }}>
          {job.salary}
        </p>

        {/* Company + location */}
        <div className="flex items-center gap-3 mt-2">
          <span style={{ fontSize: "13px", color: "#666" }}>{job.company}</span>
        </div>
        <div className="flex items-center gap-1 mt-1">
          <MapPin size={11} color="#bbb" />
          <span style={{ fontSize: "11px", color: "#bbb" }}>{job.location}</span>
          <span className="mx-1" style={{ color: "#ddd" }}>·</span>
          <Clock size={11} color="#bbb" />
          <span style={{ fontSize: "11px", color: "#bbb" }}>{job.posted}</span>
        </div>

        {/* Tags */}
        <div className="flex flex-wrap gap-1.5 mt-3">
          {job.tags.map((tag) => (
            <span
              key={tag}
              className="rounded-full px-3 py-1"
              style={{
                background: "#F5F5FA",
                fontSize: "11px",
                color: "#888",
              }}
            >
              {tag}
            </span>
          ))}
        </div>

        {/* View detail button */}
        <div className="flex items-center justify-between mt-4 pt-4 border-t border-gray-50">
          <div className="flex items-center gap-1">
            <Star size={12} color="#FFB840" fill="#FFB840" />
            <Star size={12} color="#FFB840" fill="#FFB840" />
            <Star size={12} color="#FFB840" fill="#FFB840" />
            <Star size={12} color="#FFB840" fill="#FFB840" />
            <Star size={12} color="#E0E0E0" />
            <span style={{ fontSize: "10px", color: "#bbb", marginLeft: "4px" }}>4.0 公司评分</span>
          </div>
          <motion.button
            whileTap={{ scale: 0.95 }}
            onClick={() => setShowDetail(true)}
            className="rounded-full px-5 py-2 text-white"
            style={{
              background: "linear-gradient(135deg, #667EEA, #764BA2)",
              fontSize: "12px",
              fontWeight: 600,
            }}
          >
            查看详情
          </motion.button>
        </div>
      </motion.div>

      {/* Detail modal */}
      <AnimatePresence>
        {showDetail && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 z-40 bg-black/40"
              style={{ backdropFilter: "blur(6px)" }}
              onClick={() => setShowDetail(false)}
            />
            <motion.div
              initial={{ opacity: 0, y: "100%" }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: "100%" }}
              transition={{ type: "spring", stiffness: 350, damping: 35 }}
              className="fixed z-50 left-0 right-0 bottom-0 rounded-t-3xl p-6"
              style={{
                background: "white",
                maxHeight: "75%",
                overflow: "auto",
              }}
            >
              <div className="flex items-center justify-between mb-5">
                <div>
                  <h2 style={{ fontSize: "20px", fontWeight: 700, color: "#1a1a2e" }}>
                    {job.title}
                  </h2>
                  <p style={{ fontSize: "16px", color: job.salaryColor, fontWeight: 700, marginTop: "4px" }}>
                    {job.salary}
                  </p>
                </div>
                <button onClick={() => setShowDetail(false)}>
                  <X size={22} color="#ccc" />
                </button>
              </div>

              <div
                className="rounded-2xl p-4 mb-4"
                style={{ background: "#F8F8FC" }}
              >
                <p style={{ fontSize: "13px", color: "#444", fontWeight: 600 }}>{job.company}</p>
                <p style={{ fontSize: "12px", color: "#888", marginTop: "4px" }}>{job.location}</p>
                <div className="flex flex-wrap gap-2 mt-3">
                  {job.tags.map((tag) => (
                    <span
                      key={tag}
                      className="rounded-full px-3 py-1"
                      style={{ background: "white", fontSize: "11px", color: "#888" }}
                    >
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div className="mb-5">
                <h4 style={{ fontSize: "14px", fontWeight: 600, color: "#2a2a3a", marginBottom: "8px" }}>
                  职位描述
                </h4>
                <p style={{ fontSize: "13px", color: "#666", lineHeight: "1.8" }}>
                  {job.desc}
                </p>
              </div>

              <motion.button
                whileTap={{ scale: 0.97 }}
                className="w-full py-4 rounded-2xl text-white"
                style={{
                  background: "linear-gradient(135deg, #667EEA, #764BA2)",
                  fontSize: "16px",
                  fontWeight: 600,
                }}
              >
                立即投递 🚀
              </motion.button>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  );
}

// Fishing bird illustration at the bottom
function FishingBird() {
  return (
    <motion.div
      className="flex flex-col items-center py-8 px-4"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.8 }}
    >
      {/* Water */}
      <div
        className="relative w-full rounded-2xl overflow-hidden mb-3"
        style={{ height: "120px", background: "linear-gradient(180deg, #B8E8FF 0%, #80C8F0 100%)" }}
      >
        {/* Waves */}
        {[0, 1, 2].map((i) => (
          <motion.div
            key={i}
            className="absolute"
            style={{
              bottom: "30px",
              left: `${20 + i * 30}%`,
              width: "40px",
              height: "8px",
              borderRadius: "50%",
              border: "1.5px solid rgba(255,255,255,0.5)",
            }}
            animate={{ scaleX: [1, 1.5, 1], opacity: [0.5, 0.8, 0.5] }}
            transition={{ duration: 2 + i * 0.5, repeat: Infinity, delay: i * 0.4 }}
          />
        ))}

        {/* Fish */}
        <motion.div
          className="absolute"
          style={{ fontSize: "14px" }}
          animate={{
            x: [-10, 200, -10],
            y: [60, 55, 65, 60],
          }}
          transition={{
            x: { duration: 8, repeat: Infinity, ease: "linear" },
            y: { duration: 2, repeat: Infinity, ease: "easeInOut" },
          }}
        >
          🐟
        </motion.div>
        <motion.div
          className="absolute"
          style={{ fontSize: "12px" }}
          animate={{
            x: [280, 20, 280],
            y: [50, 65, 50],
          }}
          transition={{
            x: { duration: 11, repeat: Infinity, ease: "linear" },
            y: { duration: 3, repeat: Infinity, ease: "easeInOut" },
          }}
        >
          🐠
        </motion.div>

        {/* Bird fishing */}
        <div
          className="absolute flex flex-col items-center"
          style={{ left: "50%", transform: "translateX(-50%)", top: "-10px" }}
        >
          <motion.div
            animate={{ rotate: [-3, 3, -3] }}
            transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
          >
            <img
              src={birdImg}
              alt="钓鱼的咕咕"
              style={{ width: "64px", height: "auto" }}
            />
          </motion.div>
          {/* Fishing line */}
          <motion.div
            style={{
              width: "1.5px",
              background: "rgba(100,80,60,0.6)",
              marginTop: "-4px",
            }}
            animate={{ height: [40, 55, 40] }}
            transition={{ duration: 2.5, repeat: Infinity, ease: "easeInOut" }}
          />
          <motion.div style={{ fontSize: "10px", marginTop: "-2px" }}>🪝</motion.div>
        </div>
      </div>

      <p style={{ fontSize: "12px", color: "#aaa", textAlign: "center" }}>
        咕咕在等鱼上钩~
      </p>
      <p style={{ fontSize: "11px", color: "#c0b8d0", textAlign: "center", marginTop: "4px" }}>
        好岗位也在等你，别着急 🐟
      </p>
    </motion.div>
  );
}

export function JobsScreen() {
  const [searchText, setSearchText] = useState("");

  const filtered = jobs.filter(
    (j) =>
      j.title.includes(searchText) ||
      j.company.includes(searchText) ||
      j.tags.some((t) => t.includes(searchText))
  );

  return (
    <div
      className="w-full pb-4"
      style={{ background: "#F5F5F8", minHeight: "100%" }}
    >
      {/* Header */}
      <div
        className="px-5 pt-10 pb-4 sticky top-0 z-20"
        style={{
          background: "rgba(245,245,248,0.92)",
          backdropFilter: "blur(20px)",
        }}
      >
        <div className="flex items-center justify-between mb-4">
          <div>
            <p className="text-gray-400 tracking-widest" style={{ fontSize: "10px" }}>
              为你精选
            </p>
            <h1 style={{ fontSize: "20px", fontWeight: 700, color: "#1a1a2e", marginTop: "2px" }}>
              岗位聚合馆 🔍
            </h1>
          </div>
          <motion.button
            whileTap={{ scale: 0.92 }}
            className="w-10 h-10 rounded-2xl flex items-center justify-center"
            style={{ background: "white", boxShadow: "0 2px 12px rgba(0,0,0,0.08)" }}
          >
            <SlidersHorizontal size={18} color="#667EEA" />
          </motion.button>
        </div>

        {/* Search bar */}
        <div
          className="flex items-center gap-3 rounded-2xl px-4 py-3"
          style={{
            background: "white",
            boxShadow: "0 2px 12px rgba(0,0,0,0.06)",
          }}
        >
          <Search size={16} color="#bbb" />
          <input
            value={searchText}
            onChange={(e) => setSearchText(e.target.value)}
            placeholder="搜索岗位、公司或标签..."
            className="flex-1 bg-transparent outline-none"
            style={{ fontSize: "13px", color: "#444" }}
          />
        </div>
      </div>

      {/* Category pills */}
      <div className="flex gap-2 px-4 pb-3 overflow-x-auto" style={{ scrollbarWidth: "none" }}>
        {["全部", "设计", "技术", "产品", "运营", "数据"].map((cat, i) => (
          <motion.button
            key={cat}
            initial={{ opacity: 0, x: -8 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: i * 0.05 }}
            whileTap={{ scale: 0.95 }}
            className="rounded-full px-4 py-1.5 whitespace-nowrap flex-shrink-0"
            style={{
              background: i === 0 ? "linear-gradient(135deg, #667EEA, #764BA2)" : "white",
              color: i === 0 ? "white" : "#888",
              fontSize: "12px",
              fontWeight: i === 0 ? 600 : 400,
              boxShadow: "0 2px 8px rgba(0,0,0,0.06)",
            }}
          >
            {cat}
          </motion.button>
        ))}
      </div>

      {/* Results count */}
      <p className="px-5 pb-3" style={{ fontSize: "11px", color: "#bbb" }}>
        共找到 {filtered.length} 个岗位
      </p>

      {/* Job cards */}
      <div className="flex flex-col gap-3">
        {filtered.map((job, i) => (
          <JobCard key={job.id} job={job} index={i} />
        ))}
      </div>

      {/* Fishing bird */}
      <div className="px-4">
        <FishingBird />
      </div>

      {/* Disclaimer */}
      <div
        className="mx-4 mb-4 px-4 py-3 rounded-2xl text-center"
        style={{ background: "rgba(255,255,255,0.6)" }}
      >
        <p style={{ fontSize: "10px", color: "#c0b8c8", lineHeight: 1.6 }}>
          以上岗位信息均来源于公开平台聚合，仅供参考。
          <br />
          请注意识别虚假信息，保护个人隐私与财产安全。
        </p>
      </div>
    </div>
  );
}
