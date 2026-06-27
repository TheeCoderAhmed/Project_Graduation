const C = {
  black: "#030507",
  board: "#06111a",
  board2: "#071f2f",
  panel: "#fbfcfd",
  paper: "#ffffff",
  ink: "#12181f",
  muted: "#46515d",
  line: "#d7dce2",
  burgundy: "#a90438",
  burgundy2: "#7e0028",
  blue: "#2769d8",
  cyan: "#8ff7ee",
  primary: "#074469",
  primarySoft: "#e8f2fb",
  primary2: "#2a5c82",
  teal: "#006a68",
  tealSoft: "#91f0ec",
  amber: "#f1be72",
  amberDark: "#76510e",
  redSoft: "#ffdad6",
};

function rect(slide, ctx, x, y, w, h, fill, line = "#00000000", width = 0) {
  return ctx.addShape(slide, {
    x,
    y,
    w,
    h,
    fill,
    line: { style: "solid", fill: line, width },
    geometry: "rect",
  });
}

function ellipse(slide, ctx, x, y, w, h, fill, line = "#00000000", width = 0) {
  return ctx.addShape(slide, {
    x,
    y,
    w,
    h,
    fill,
    line: { style: "solid", fill: line, width },
    geometry: "ellipse",
  });
}

function text(slide, ctx, value, x, y, w, h, opts = {}) {
  return ctx.addText(slide, {
    text: value,
    x,
    y,
    w,
    h,
    fontSize: opts.size ?? 20,
    color: opts.color ?? C.ink,
    bold: opts.bold ?? false,
    typeface: opts.face ?? "Aptos",
    align: opts.align ?? "left",
    valign: opts.valign ?? "top",
    fill: opts.fill ?? "#00000000",
    line: { style: "solid", fill: "#00000000", width: 0 },
    insets: opts.insets ?? { left: 0, right: 0, top: 0, bottom: 0 },
  });
}

function rule(slide, ctx, x, y, w, color = C.line, h = 2) {
  rect(slide, ctx, x, y, w, h, color);
}

async function icon(slide, ctx, name, x, y, size = 24, color = C.primary, strokeWidth = 2) {
  return ctx.addLucideIcon(slide, {
    icon: name,
    x,
    y,
    w: size,
    h: size,
    color,
    strokeWidth,
    fit: "contain",
  });
}

function wrap(textValue, maxChars, maxLines = 3) {
  const words = String(textValue).split(/\s+/);
  const lines = [];
  let line = "";
  for (const word of words) {
    const candidate = line ? `${line} ${word}` : word;
    if (candidate.length > maxChars && line) {
      lines.push(line);
      line = word;
      if (lines.length === maxLines - 1) break;
    } else {
      line = candidate;
    }
  }
  if (line && lines.length < maxLines) lines.push(line);
  return lines.join("\n");
}

function panel(slide, ctx, x, y, w, h, title, opts = {}) {
  rect(slide, ctx, x + 7, y + 9, w, h, "#00000066");
  rect(slide, ctx, x, y, w, h, C.panel, opts.line ?? C.burgundy, 1.2);
  rect(slide, ctx, x, y, w, opts.headerH ?? 44, opts.header ?? C.burgundy);
  text(slide, ctx, title, x + 14, y + 10, w - 28, 24, {
    size: opts.titleSize ?? 21,
    color: "#ffffff",
    bold: true,
    align: opts.titleAlign ?? "center",
    face: "Aptos Display",
  });
}

function bullet(slide, ctx, x, y, textValue, color = C.primary, size = 11.5, width = 250) {
  rect(slide, ctx, x, y + 5, 6, 6, color);
  text(slide, ctx, textValue, x + 14, y, width, 30, { size, color: C.ink });
}

async function miniMetric(slide, ctx, x, y, value, label, iconName, color) {
  rect(slide, ctx, x, y, 130, 62, "#f4f8fb", "#d7dce2", 1);
  await icon(slide, ctx, iconName, x + 11, y + 17, 22, color, 2.2);
  text(slide, ctx, value, x + 40, y + 9, 78, 26, {
    size: value.length > 4 ? 18 : 24,
    color,
    bold: true,
    face: "Aptos Display",
  });
  text(slide, ctx, label, x + 12, y + 39, 108, 14, {
    size: 8.8,
    color: C.muted,
    bold: true,
    align: "center",
  });
}

async function phone(slide, ctx, file, x, y, w, label, color) {
  const h = w * 2.165;
  rect(slide, ctx, x + 10, y + 13, w, h, "#00000038");
  rect(slide, ctx, x, y, w, h, "#051722", "#051722", 1.2);
  rect(slide, ctx, x + 8, y + 12, w - 16, h - 24, "#f9f9fd");
  await ctx.addImage(slide, {
    path: `${ctx.assetDir}/${file}`,
    x: x + 8,
    y: y + 12,
    w: w - 16,
    h: h - 24,
    fit: "cover",
    alt: label,
  });
  rect(slide, ctx, x + w * 0.36, y + 6, w * 0.28, 4, "#d9dadd");
  rect(slide, ctx, x + 6, y + h + 8, w - 12, 28, color);
  text(slide, ctx, label, x + 8, y + h + 15, w - 16, 14, {
    size: 9.3,
    color: "#ffffff",
    bold: true,
    align: "center",
  });
}

async function archBox(slide, ctx, x, y, w, title, body, iconName, color) {
  rect(slide, ctx, x, y, w, 72, "#ffffff", "#cfd6de", 1);
  rect(slide, ctx, x, y, 5, 72, color);
  await icon(slide, ctx, iconName, x + 13, y + 20, 23, color, 2.2);
  text(slide, ctx, title, x + 46, y + 13, w - 58, 18, { size: 12.8, color: C.ink, bold: true });
  text(slide, ctx, body, x + 46, y + 35, w - 58, 26, { size: 8.8, color: C.muted });
}

async function arrowRight(slide, ctx, x, y, w, color = C.primary2) {
  rule(slide, ctx, x, y + 13, w - 18, color, 2);
  await icon(slide, ctx, "ArrowRight", x + w - 24, y + 1, 24, color, 2.2);
}

function weight(slide, ctx, x, y, label, pct, color) {
  text(slide, ctx, label, x, y, 122, 14, { size: 8.8, color: C.ink, bold: true });
  rect(slide, ctx, x + 130, y + 4, 92, 8, "#e1e5ea");
  rect(slide, ctx, x + 130, y + 4, 92 * pct, 8, color);
  text(slide, ctx, `${Math.round(pct * 100)}%`, x + 228, y - 1, 30, 12, {
    size: 8.5,
    color,
    bold: true,
    align: "right",
  });
}

async function header(slide, ctx) {
  rect(slide, ctx, 0, 0, 1080, 1920, C.black);
  rect(slide, ctx, 0, 0, 1080, 252, "#02070b");
  rect(slide, ctx, 58, 42, 110, 4, C.burgundy);
  rect(slide, ctx, 912, 42, 110, 4, C.burgundy);
  rect(slide, ctx, 86, 224, 64, 6, C.teal);
  rect(slide, ctx, 160, 224, 42, 6, C.blue);
  rect(slide, ctx, 878, 224, 42, 6, C.blue);
  rect(slide, ctx, 930, 224, 64, 6, C.teal);
  text(slide, ctx, "DRAPO", 0, 28, 1080, 60, {
    size: 44,
    color: "#ffb4c8",
    bold: true,
    align: "center",
    face: "Aptos Display",
  });
  text(slide, ctx, "Patient-Centric Rating and Evaluation Platform for Healthcare Providers", 142, 88, 796, 32, {
    size: 18.5,
    color: "#ffffff",
    bold: true,
    align: "center",
  });
  text(slide, ctx, "CMPE/ISE/SE 494 Senior Project", 0, 148, 1080, 34, {
    size: 26,
    color: C.blue,
    bold: true,
    align: "center",
    face: "Aptos Display",
  });
  text(slide, ctx, "Supervisor: Prof. Dr. Hürevren KILIÇ | Flutter + Firebase independent decision-support mobile app", 0, 194, 1080, 22, {
    size: 14,
    color: "#d7e7ff",
    align: "center",
  });
  rule(slide, ctx, 44, 238, 992, C.burgundy, 4);
}

async function buildTeam(slide, ctx) {
  panel(slide, ctx, 32, 286, 302, 192, "Team");
  const members = [
    ["Ahmed Nasser Haidar", "20244710088"],
    ["Ruşen Emir Ramazanoğlu", "21243510122"],
    ["Alireza Rahmani Ghahroudi", "20243510082"],
    ["Parnia Helchi", "22243610087"],
    ["Omer Ahmed Awni Alobaida", "20244710103"],
    ["Aleyna Duru Koç", "24244710045"],
  ];
  text(slide, ctx, "DRAPO Dev Team", 52, 346, 250, 16, { size: 12.5, color: C.primary, bold: true });
  members.forEach(([name, id], i) => {
    const y = 364 + i * 15;
    text(slide, ctx, name, 54, y, 156, 12, { size: 7.9, color: C.ink, bold: true });
    text(slide, ctx, id, 212, y, 78, 12, { size: 7.7, color: i % 2 ? C.teal : C.primary, bold: true, align: "right" });
  });
  rule(slide, ctx, 54, 456, 240, "#d7dce2", 1);
  text(slide, ctx, "Supervisor: Prof. Dr. Hürevren KILIÇ", 54, 462, 240, 12, {
    size: 8.3,
    color: C.burgundy,
    bold: true,
  });
}

async function buildObjective(slide, ctx) {
  panel(slide, ctx, 32, 510, 302, 260, "Objective");
  text(slide, ctx, "Reduce healthcare information asymmetry by turning real post-visit experiences into structured, comparable provider rankings for doctors, pharmacies, and clinics.", 54, 588, 252, 58, {
    size: 11.2,
    color: C.ink,
  });
  rect(slide, ctx, 54, 660, 250, 66, C.primarySoft, "#cde5ff", 1);
  text(slide, ctx, "Project stance", 68, 672, 100, 14, { size: 10, color: C.primary, bold: true });
  text(slide, ctx, "DRAPO is not a hospital record system. It stores no diagnoses, prescriptions, or treatment histories; it focuses on non-clinical service quality.", 68, 692, 210, 28, {
    size: 8.8,
    color: C.primary,
    bold: true,
  });
  text(slide, ctx, "Outcome: help patients choose with evidence while giving providers feedback they can act on.", 56, 742, 246, 18, {
    size: 8.7,
    color: C.muted,
  });
}

async function buildApplication(slide, ctx) {
  panel(slide, ctx, 32, 806, 302, 300, "Application Areas", { titleSize: 20 });
  const items = [
    ["Patients", "search, compare, save, and review providers"],
    ["Providers", "monitor trends, strengths, and improvement areas"],
    ["Admins", "moderate data and maintain provider quality"],
    ["Service quality", "measure waiting time, cleanliness, empathy, professionalism"],
    ["Public value", "support transparency, accountability, and SDG 3"],
  ];
  items.forEach(([label, body], i) => {
    const y = 870 + i * 42;
    rect(slide, ctx, 54, y, 250, 32, i % 2 ? "#effbf9" : "#f4f8fb", "#e2e6eb", 1);
    text(slide, ctx, label, 68, y + 7, 90, 14, { size: 9.7, color: i % 2 ? C.teal : C.primary, bold: true });
    text(slide, ctx, body, 150, y + 7, 134, 16, { size: 8.4, color: C.muted });
  });
}

async function buildEvidenceFigure(slide, ctx) {
  panel(slide, ctx, 32, 1142, 302, 280, "Project Evidence", { titleSize: 18 });
  await miniMetric(slide, ctx, 54, 1204, "9", "Scrum sprints", "Kanban", C.teal);
  await miniMetric(slide, ctx, 184, 1204, "154", "automated tests", "FlaskConical", C.primary);
  await miniMetric(slide, ctx, 54, 1282, "78.75", "SUS mean", "Users", C.teal);
  await miniMetric(slide, ctx, 184, 1282, "0", "critical crashes", "ShieldCheck", C.amberDark);
  text(slide, ctx, "Performance summary from final report: provider search 1.2 sec, review submission <1 sec, screen transitions 0.8 sec, and 92% successful functional scenarios.", 58, 1370, 236, 42, {
    size: 9,
    color: C.muted,
  });
}

async function buildArchitecture(slide, ctx) {
  panel(slide, ctx, 370, 270, 344, 656, "Design and Architecture", { titleSize: 20 });
  text(slide, ctx, "Layered mobile architecture with server-side score integrity", 392, 338, 300, 28, {
    size: 13,
    color: C.primary,
    bold: true,
    align: "center",
  });
  await archBox(slide, ctx, 394, 386, 296, "Presentation Layer", "Flutter UI: auth, discovery, provider profile, questionnaire", "Smartphone", C.primary);
  rect(slide, ctx, 540, 458, 4, 20, C.burgundy);
  await archBox(slide, ctx, 394, 482, 296, "Application Service Layer", "Auth, provider search, review management, questionnaire processing", "Workflow", C.teal);
  rect(slide, ctx, 540, 554, 4, 20, C.burgundy);
  await archBox(slide, ctx, 394, 578, 296, "Business Logic Layer", "AHP-inspired ranking, validation engine, analytics dashboard", "TrendingUp", C.primary2);
  rect(slide, ctx, 540, 650, 4, 20, C.burgundy);
  await archBox(slide, ctx, 394, 674, 296, "Backend Cloud Infrastructure", "Firebase Auth, Firestore, Storage, Cloud Functions", "Cloud", C.amberDark);
  rect(slide, ctx, 394, 774, 296, 66, "#f7fafc", "#d7dce2", 1);
  text(slide, ctx, "Architecture views", 410, 790, 130, 14, { size: 10.5, color: C.burgundy, bold: true });
  text(slide, ctx, "Logical: Patient, Provider, Admin actors\nProcess: review write -> ranking trigger\nDeployment: Flutter client + Firebase cloud", 410, 812, 250, 28, {
    size: 8.4,
    color: C.muted,
  });
  rect(slide, ctx, 394, 854, 296, 58, "#effbf9", "#d7dce2", 1);
  text(slide, ctx, "Privacy and trust constraints", 410, 868, 158, 14, { size: 10.5, color: C.teal, bold: true });
  text(slide, ctx, "KVKK-aware data minimization, authenticated access, anonymous reviews, no clinical records, and backend-protected ranking updates.", 410, 888, 250, 18, {
    size: 8.1,
    color: C.muted,
  });
}

async function buildMethods(slide, ctx) {
  panel(slide, ctx, 370, 960, 344, 810, "Methods/Tools", { titleSize: 20 });
  text(slide, ctx, "Methodology + toolchain", 394, 1026, 180, 16, { size: 12.5, color: C.primary, bold: true });
  const stack = [
    "Agile Scrum: 16 weeks / 9 sprints",
    "Flutter 3.19+ / Dart 3.3+",
    "Provider state management",
    "Firebase Auth, Firestore, Storage",
    "Cloud Functions v2 for ranking updates",
    "Git/GitHub, VS Code, Cursor",
    "Firebase Spark Tier cost constraint",
  ];
  stack.forEach((s, i) => bullet(slide, ctx, 398, 1054 + i * 24, s, i % 2 ? C.teal : C.primary, 9.6, 250));
  rect(slide, ctx, 394, 1224, 296, 186, "#f4f8fb", "#d7dce2", 1);
  text(slide, ctx, "AHP-inspired ranking method", 414, 1242, 190, 16, { size: 12, color: C.burgundy, bold: true });
  text(slide, ctx, "Weighted score = sum(criteria weight x patient score)", 414, 1268, 238, 20, {
    size: 10,
    color: C.ink,
    bold: true,
  });
  weight(slide, ctx, 414, 1304, "Communication quality", 0.30, C.primary);
  weight(slide, ctx, 414, 1328, "Cleanliness", 0.20, C.teal);
  weight(slide, ctx, 414, 1352, "Professionalism", 0.20, C.primary2);
  weight(slide, ctx, 414, 1376, "Waiting time", 0.15, C.amberDark);
  weight(slide, ctx, 414, 1400, "Empathy", 0.15, C.burgundy);
  rect(slide, ctx, 394, 1432, 296, 260, "#ffffff", "#d7dce2", 1);
  text(slide, ctx, "Verification method", 414, 1450, 150, 16, { size: 12, color: C.primary, bold: true });
  bullet(slide, ctx, 418, 1482, "154 automated tests across models, widgets, routes, and utility calculations", C.primary, 9.1, 236);
  bullet(slide, ctx, 418, 1524, "Integration checks for authentication, cache failover, stream updates, and review writes", C.teal, 9.1, 236);
  bullet(slide, ctx, 418, 1572, "UAT with 6 participants on Samsung Galaxy A54: T1/T2 100%, T3 83%, T5 67%", C.primary2, 9.1, 236);
  bullet(slide, ctx, 418, 1620, "SUS mean 78.75; core flows tested for search, profile access, questionnaire, bookmarking", C.burgundy, 9.1, 236);
  rect(slide, ctx, 394, 1710, 296, 42, "#effbf9", "#d7dce2", 1);
  text(slide, ctx, "Questionnaire captures communication, cleanliness, professionalism, waiting time, empathy, comments, and anonymous review preference.", 412, 1722, 252, 18, {
    size: 8.2,
    color: C.muted,
  });
}

async function buildInterfaces(slide, ctx) {
  panel(slide, ctx, 744, 286, 312, 640, "Interfaces");
  await phone(slide, ctx, "phone_home.png", 774, 360, 92, "Home / Discovery", C.primary);
  await phone(slide, ctx, "phone_questionnaire.png", 874, 390, 92, "Review Form", C.teal);
  await phone(slide, ctx, "phone_provider_dashboard.png", 944, 360, 92, "Dashboard", C.amberDark);
  rect(slide, ctx, 768, 642, 254, 116, "#f4f8fb", "#d7dce2", 1);
  text(slide, ctx, "Implemented mobile flows", 784, 660, 170, 16, { size: 11, color: C.primary, bold: true });
  bullet(slide, ctx, 788, 692, "secure login, profile management, and role-aware navigation", C.primary, 8.5, 210);
  bullet(slide, ctx, 788, 720, "search by name, specialty, provider category, and location", C.teal, 8.5, 210);
  bullet(slide, ctx, 788, 748, "structured review form, star rating, anonymity option, analytics", C.amberDark, 8.5, 210);
  rect(slide, ctx, 768, 786, 254, 88, "#effbf9", "#d7dce2", 1);
  text(slide, ctx, "Interface principle", 784, 804, 140, 16, { size: 11, color: C.teal, bold: true });
  text(slide, ctx, "Simple, modern, mobile-first screens designed for low-friction provider discovery and guided feedback entry after a visit.", 784, 832, 214, 28, {
    size: 8.7,
    color: C.muted,
  });
}

async function buildConclusion(slide, ctx) {
  panel(slide, ctx, 744, 960, 312, 274, "Conclusion");
  text(slide, ctx, "DRAPO achieved its primary goal: a scalable patient-centered platform that combines mobile access, cloud backend infrastructure, and weighted service-quality evaluation.", 768, 1030, 248, 54, {
    size: 11.2,
    color: C.ink,
  });
  bullet(slide, ctx, 772, 1100, "patients gain clearer non-clinical comparison signals", C.primary, 9, 230);
  bullet(slide, ctx, 772, 1132, "providers gain structured feedback for improvement", C.teal, 9, 230);
  bullet(slide, ctx, 772, 1164, "future: appointments, AI fraud detection, advanced analytics, larger provider database", C.burgundy, 9, 230);
}

async function buildReferences(slide, ctx) {
  panel(slide, ctx, 744, 1272, 312, 500, "References");
  const refs = [
    "Final Project Report — team, objectives, metrics, methods, conclusions.",
    "WHO (2023) — digital health transformation context.",
    "Liu & Jiang (2021) — communication quality and patient trust.",
    "Al Awadh (2022) — multi-criteria healthcare service evaluation.",
    "Fentaw (2020); Zarichuk (2023) — cross-platform mobile development.",
    "Valkamo (2025) — mHealth and real-time mobile application context.",
    "README.md / TEST_REPORT.md — implementation and automated test evidence.",
    "aggregation.js / firestore.rules — weighted ranking and backend trust controls.",
  ];
  refs.forEach((ref, i) => bullet(slide, ctx, 766, 1340 + i * 41, wrap(ref, 42, 2), i % 2 ? C.teal : C.primary, 8.4, 238));
}

export async function slide01(presentation, ctx) {
  const slide = presentation.slides.add();
  await header(slide, ctx);
  await buildTeam(slide, ctx);
  await buildObjective(slide, ctx);
  await buildApplication(slide, ctx);
  await buildEvidenceFigure(slide, ctx);
  await buildArchitecture(slide, ctx);
  await buildMethods(slide, ctx);
  await buildInterfaces(slide, ctx);
  await buildConclusion(slide, ctx);
  await buildReferences(slide, ctx);
  text(slide, ctx, "2025-26 Spring | DRAPO Dev Team | Patient-centered healthcare service transparency through structured feedback and weighted rankings", 32, 1810, 1018, 22, {
    size: 9,
    color: "#d7e7ff",
    align: "center",
  });
  return slide;
}
