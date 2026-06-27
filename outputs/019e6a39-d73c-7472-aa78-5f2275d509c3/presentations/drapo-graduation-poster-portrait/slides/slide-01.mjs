const C = {
  bg: "#f9f9fd",
  paper: "#ffffff",
  paper2: "#f3f3f7",
  ink: "#191c1e",
  muted: "#41474e",
  line: "#c1c7cf",
  primary: "#074469",
  primary2: "#2a5c82",
  primarySoft: "#cde5ff",
  teal: "#006a68",
  tealSoft: "#91f0ec",
  amber: "#f1be72",
  amberDark: "#76510e",
  red: "#ba1a1a",
  dark: "#032f49",
};

function wrapWords(text, maxChars, maxLines = 4) {
  const words = String(text).split(/\s+/);
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
    fontSize: opts.size ?? 24,
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

async function icon(slide, ctx, name, x, y, size = 28, color = C.primary, strokeWidth = 2) {
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

function sectionTitle(slide, ctx, kicker, title, x, y, w) {
  text(slide, ctx, kicker, x, y, w, 18, { size: 13, color: C.teal, bold: true });
  text(slide, ctx, title, x, y + 30, w, 52, {
    size: 31,
    color: C.ink,
    bold: true,
    face: "Aptos Display",
  });
}

function chip(slide, ctx, value, x, y, w, color = "#ffffff", fill = "#ffffff12") {
  rect(slide, ctx, x, y, w, 30, fill, `${color}55`, 1);
  text(slide, ctx, value, x + 10, y + 7, w - 20, 16, {
    size: 11.8,
    color,
    bold: true,
    align: "center",
  });
}

async function darkMetric(slide, ctx, x, y, value, label, iconName, color) {
  rect(slide, ctx, x, y, 238, 82, "#ffffff12", "#ffffff33", 1);
  await icon(slide, ctx, iconName, x + 18, y + 20, 28, color, 2.2);
  text(slide, ctx, value, x + 60, y + 12, 154, 34, {
    size: 32,
    color,
    bold: true,
    face: "Aptos Display",
  });
  text(slide, ctx, label, x + 60, y + 51, 150, 18, {
    size: 12,
    color: "#ffffffd8",
    bold: true,
  });
}

async function flowNode(slide, ctx, x, y, w, h, title, body, iconName, color) {
  rect(slide, ctx, x + 6, y + 7, w, h, "#07446912");
  rect(slide, ctx, x, y, w, h, C.paper, "#d9dadd", 1.2);
  rect(slide, ctx, x, y, 5, h, color);
  await icon(slide, ctx, iconName, x + 18, y + 22, 28, color, 2.2);
  text(slide, ctx, title, x + 60, y + 17, w - 76, 24, { size: 16, color: C.ink, bold: true });
  text(slide, ctx, body, x + 60, y + 47, w - 76, h - 54, { size: 11.5, color: C.muted });
}

async function downArrow(slide, ctx, x, y, color = C.primary2) {
  rule(slide, ctx, x, y, 3, color, 40);
  await icon(slide, ctx, "ArrowDown", x - 13, y + 29, 28, color, 2.5);
}

function weightBar(slide, ctx, x, y, label, value, color) {
  const maxW = 230;
  text(slide, ctx, label, x, y, 188, 20, { size: 12.5, color: C.ink, bold: true });
  rect(slide, ctx, x + 200, y + 5, maxW, 12, "#e2e2e6");
  rect(slide, ctx, x + 200, y + 5, maxW * value, 12, color);
  text(slide, ctx, `${Math.round(value * 100)}%`, x + 438, y - 1, 46, 20, {
    size: 12,
    color,
    bold: true,
    align: "right",
  });
}

async function proofCard(slide, ctx, x, y, w, value, label, note, iconName, color) {
  rect(slide, ctx, x, y, w, 94, C.paper, "#d9dadd", 1);
  await icon(slide, ctx, iconName, x + 18, y + 20, 26, color, 2.2);
  text(slide, ctx, value, x + 58, y + 13, w - 70, 32, {
    size: value.length > 4 ? 25 : 31,
    color,
    bold: true,
    face: "Aptos Display",
  });
  text(slide, ctx, label, x + 20, y + 53, w - 40, 17, { size: 12.2, color: C.ink, bold: true });
  text(slide, ctx, note, x + 20, y + 72, w - 40, 14, { size: 9.2, color: C.muted });
}

function miniBar(slide, ctx, x, y, label, value, max, color) {
  text(slide, ctx, label, x, y, 36, 14, { size: 9.5, color: C.muted, bold: true, align: "center" });
  const h = 58 * (value / max);
  rect(slide, ctx, x + 8, y + 72 - h, 24, h, color);
  text(slide, ctx, String(value), x, y + 78, 40, 14, { size: 9, color: C.muted, align: "center" });
}

async function featureRow(slide, ctx, x, y, w, iconName, title, body, color) {
  rect(slide, ctx, x, y, w, 92, C.paper, "#d9dadd", 1);
  rect(slide, ctx, x, y, 6, 92, color);
  await icon(slide, ctx, iconName, x + 20, y + 22, 30, color, 2.2);
  text(slide, ctx, title, x + 66, y + 16, w - 84, 22, { size: 16, color: C.ink, bold: true });
  text(slide, ctx, wrapWords(body, 78, 2), x + 66, y + 46, w - 84, 34, { size: 11.8, color: C.muted });
}

async function phone(slide, ctx, file, x, y, w, label, color) {
  const h = w * 2.165;
  rect(slide, ctx, x + 11, y + 14, w, h, "#001d3222");
  rect(slide, ctx, x, y, w, h, "#061e2c", "#061e2c", 1.2);
  rect(slide, ctx, x + 10, y + 13, w - 20, h - 26, "#f9f9fd");
  await ctx.addImage(slide, {
    path: `${ctx.assetDir}/${file}`,
    x: x + 10,
    y: y + 13,
    w: w - 20,
    h: h - 26,
    fit: "cover",
    alt: label,
  });
  rect(slide, ctx, x + w * 0.36, y + 7, w * 0.28, 5, "#d9dadd");
  rect(slide, ctx, x + 7, y + h + 10, w - 14, 32, color);
  text(slide, ctx, label, x + 10, y + h + 17, w - 20, 18, {
    size: 10.8,
    color: "#ffffff",
    bold: true,
    align: "center",
  });
}

async function buildHeader(slide, ctx) {
  rect(slide, ctx, 0, 0, 1080, 442, C.dark);
  rect(slide, ctx, 0, 0, 18, 442, C.teal);
  ellipse(slide, ctx, 710, -185, 420, 420, "#91f0ec18");
  ellipse(slide, ctx, 805, 185, 330, 330, "#cde5ff14");
  rect(slide, ctx, 60, 55, 72, 72, "#ffffff12", "#91f0ec66", 1.2);
  await icon(slide, ctx, "HeartPulse", 79, 75, 34, C.tealSoft, 2.4);
  text(slide, ctx, "CMPE/ISE/SE 494 GRADUATION PROJECT", 152, 60, 430, 18, {
    size: 13,
    color: C.tealSoft,
    bold: true,
  });
  text(slide, ctx, "Spring 2025-26", 152, 86, 180, 18, { size: 13, color: "#ffffffcc" });
  text(slide, ctx, "DRAPO", 58, 150, 440, 86, {
    size: 84,
    color: "#ffffff",
    bold: true,
    face: "Aptos Display",
  });
  text(slide, ctx, "Patient-Centric Healthcare Review Platform", 62, 245, 560, 48, {
    size: 30,
    color: "#ffffff",
    bold: true,
    face: "Aptos Display",
  });
  text(
    slide,
    ctx,
    "A Flutter + Firebase mobile app that turns post-visit feedback into structured provider discovery, role-aware workflows, and server-side weighted rankings.",
    64,
    310,
    610,
    72,
    { size: 16.2, color: "#e2f4ff" },
  );
  chip(slide, ctx, "Flutter 3.19+", 64, 390, 112);
  chip(slide, ctx, "Firebase Auth", 188, 390, 128);
  chip(slide, ctx, "Firestore", 328, 390, 96);
  chip(slide, ctx, "Cloud Functions v2", 436, 390, 158);
  chip(slide, ctx, "Provider state", 606, 390, 124);

  await darkMetric(slide, ctx, 774, 62, "8541", "Dart lines in lib/", "Activity", C.tealSoft);
  await darkMetric(slide, ctx, 774, 164, "154", "Dart tests", "FlaskConical", C.amber);
  await darkMetric(slide, ctx, 774, 266, "78.75", "Mean SUS score", "Gauge", "#ffffff");
}

async function buildChallenge(slide, ctx) {
  sectionTitle(slide, ctx, "DESIGN CHALLENGE", "Healthcare reviews need more than a star average.", 60, 486, 650);
  rect(slide, ctx, 60, 590, 288, 78, "#ffdad6", "#ffdad6", 1);
  text(slide, ctx, "Problem", 78, 606, 120, 18, { size: 12, color: "#93000a", bold: true });
  text(slide, ctx, "Single-star ratings flatten service quality and weaken trust.", 78, 630, 238, 28, {
    size: 12.5,
    color: "#93000a",
    bold: true,
  });
  rect(slide, ctx, 382, 590, 288, 78, C.primarySoft, C.primarySoft, 1);
  text(slide, ctx, "Method", 400, 606, 120, 18, { size: 12, color: C.primary, bold: true });
  text(slide, ctx, "Structure reviews, enforce deterministic IDs, aggregate server-side.", 400, 630, 242, 28, {
    size: 12.5,
    color: C.primary,
    bold: true,
  });
  rect(slide, ctx, 704, 590, 316, 78, C.tealSoft, C.tealSoft, 1);
  text(slide, ctx, "Outcome", 722, 606, 120, 18, { size: 12, color: C.teal, bold: true });
  text(slide, ctx, "Ranked discovery with patient, provider, admin, and community flows.", 722, 630, 258, 28, {
    size: 12.5,
    color: C.teal,
    bold: true,
  });
}

async function buildWorkflow(slide, ctx) {
  sectionTitle(slide, ctx, "SYSTEM WORKFLOW", "Trust is built into the data path.", 60, 716, 500);
  const x = 60;
  const w = 470;
  await flowNode(slide, ctx, x, 824, w, 78, "Patient App", "search, bookmark, submit structured review", "Smartphone", C.primary);
  await downArrow(slide, ctx, x + w / 2, 912, C.primary2);
  await flowNode(slide, ctx, x, 980, w, 78, "Auth + Role Gate", "patient / provider / admin navigation and permissions", "UserRoundCheck", C.teal);
  await downArrow(slide, ctx, x + w / 2, 1068, C.primary2);
  await flowNode(slide, ctx, x, 1136, w, 78, "Firestore Collections", "users, providers, reviews, community_doctors, community_reviews", "Database", C.primary2);

  const x2 = 566;
  await flowNode(slide, ctx, x2, 824, 454, 78, "Structured Review", "overall rating plus waiting time, service, hygiene, staff communication", "ClipboardCheck", C.amberDark);
  await downArrow(slide, ctx, x2 + 227, 912, C.primary2);
  await flowNode(slide, ctx, x2, 980, 454, 78, "Cloud Function Aggregation", "recalculateProviderStats recomputes averageRating and rankingScore", "Cloud", C.primary);
  await downArrow(slide, ctx, x2 + 227, 1068, C.primary2);
  await flowNode(slide, ctx, x2, 1136, 454, 78, "Rules + Transactions", "locked score fields, immutable reviews, atomic community aggregation", "ShieldCheck", C.teal);
}

function buildRanking(slide, ctx) {
  rect(slide, ctx, 60, 1262, 520, 260, C.paper, "#d9dadd", 1);
  text(slide, ctx, "AHP-INSPIRED RANKING", 88, 1290, 240, 18, { size: 13, color: C.teal, bold: true });
  text(slide, ctx, "rankingScore = 0.4 * averageOverallRating + 0.6 * weightedQuestionnaireScore", 88, 1324, 440, 46, {
    size: 16,
    color: C.ink,
    bold: true,
  });
  weightBar(slide, ctx, 88, 1394, "Staff communication", 0.35, C.primary);
  weightBar(slide, ctx, 88, 1434, "Hygiene", 0.25, C.teal);
  weightBar(slide, ctx, 88, 1474, "Service quality", 0.25, C.teal);
  weightBar(slide, ctx, 88, 1514, "Waiting time", 0.15, C.amberDark);
}

async function buildScreens(slide, ctx) {
  text(slide, ctx, "APP SURFACES", 620, 1262, 180, 18, { size: 13, color: C.primary, bold: true });
  text(slide, ctx, "Real project screen assets.", 620, 1292, 390, 28, {
    size: 23,
    color: C.ink,
    bold: true,
    face: "Aptos Display",
  });
  await phone(slide, ctx, "phone_home.png", 620, 1320, 104, "Discovery", C.primary);
  await phone(slide, ctx, "phone_questionnaire.png", 760, 1320, 104, "Review form", C.teal);
  await phone(slide, ctx, "phone_provider_dashboard.png", 900, 1320, 104, "Dashboard", C.amberDark);
}

async function buildValidation(slide, ctx) {
  sectionTitle(slide, ctx, "VALIDATION", "Checked with tests and real task sessions.", 60, 1600, 760);
  await proofCard(slide, ctx, 60, 1696, 178, "154", "Dart tests", "unit + widget + A/B", "FlaskConical", C.primary);
  await proofCard(slide, ctx, 252, 1696, 178, "2", "JS tests", "aggregation function", "FileCheck2", C.teal);
  await proofCard(slide, ctx, 444, 1696, 178, "78.1%", "Coverage", "~92% effective", "Gauge", C.amberDark);
  await proofCard(slide, ctx, 636, 1696, 178, "86.7%", "Task completion", "26/30 attempts", "CheckCircle2", C.primary2);
  await proofCard(slide, ctx, 828, 1696, 192, "6", "Participants", "SUS + think-aloud", "Users", C.teal);

  text(slide, ctx, "SUS score distribution", 62, 1812, 220, 16, { size: 12.5, color: C.muted, bold: true });
  const scores = [90, 73, 85, 98, 53, 75];
  const labels = ["P1", "P2", "P3", "P4", "P5", "P6"];
  scores.forEach((score, i) => miniBar(slide, ctx, 72 + i * 58, 1836, labels[i], score, 100, i === 4 ? C.red : i % 2 ? C.teal : C.primary));
  rect(slide, ctx, 464, 1818, 556, 78, "#f3f3f7", "#d9dadd", 1);
  text(slide, ctx, "Mean SUS: 78.75 (B - Good)", 488, 1834, 270, 22, { size: 17, color: C.ink, bold: true });
  text(slide, ctx, "Above industry average (68) and healthcare-app average (71.4). Next sprint: search affordance, bookmark label, emulator-backed integration coverage.", 488, 1864, 488, 24, {
    size: 10.8,
    color: C.muted,
  });
}

async function buildFooter(slide, ctx) {
  rule(slide, ctx, 60, 1898, 960, "#c1c7cf", 1);
  text(slide, ctx, "Sources: README.md, PRODUCT.md, DESIGN.md, TEST_REPORT.md, USABILITY_TEST.md, STUDY_GUIDE.md, functions/src/aggregation.js, firestore.rules, lib/services/firestore_service.dart", 60, 1918, 960, 18, {
    size: 9.7,
    color: C.muted,
  });
}

export async function slide01(presentation, ctx) {
  const slide = presentation.slides.add();
  rect(slide, ctx, 0, 0, 1080, 1920, C.bg);
  for (let x = 60; x < 1080; x += 80) rule(slide, ctx, x, 442, 1, "#e7e8eb", 1458);
  for (let y = 480; y < 1900; y += 80) rule(slide, ctx, 0, y, 1080, "#edeef1", 1);
  ellipse(slide, ctx, 770, 1120, 260, 260, "#91f0ec44");
  ellipse(slide, ctx, 790, 620, 210, 210, "#cde5ff66");

  await buildHeader(slide, ctx);
  await buildChallenge(slide, ctx);
  await buildWorkflow(slide, ctx);
  buildRanking(slide, ctx);
  await buildScreens(slide, ctx);
  await buildValidation(slide, ctx);
  await buildFooter(slide, ctx);
  return slide;
}
