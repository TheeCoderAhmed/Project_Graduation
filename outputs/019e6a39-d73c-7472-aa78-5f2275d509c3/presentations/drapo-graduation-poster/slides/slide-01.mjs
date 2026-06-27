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
  midnight: "#001d32",
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

function rect(slide, ctx, x, y, w, h, fill, line = "#00000000", width = 0, name) {
  return ctx.addShape(slide, {
    x,
    y,
    w,
    h,
    fill,
    line: { style: "solid", fill: line, width },
    geometry: "rect",
    name,
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
    typeface: opts.face ?? opts.typeface ?? "Aptos",
    align: opts.align ?? "left",
    valign: opts.valign ?? "top",
    fill: opts.fill ?? "#00000000",
    line: { style: "solid", fill: "#00000000", width: 0 },
    insets: opts.insets ?? { left: 0, right: 0, top: 0, bottom: 0 },
    name: opts.name,
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

function chip(slide, ctx, value, x, y, w, color = C.primary, fill = "#ffffff18") {
  rect(slide, ctx, x, y, w, 32, fill, `${color}55`, 1);
  text(slide, ctx, value, x + 12, y + 7, w - 24, 18, {
    size: 13,
    color,
    bold: true,
    align: "center",
  });
}

async function metric(slide, ctx, x, y, w, value, label, note, color, iconName) {
  rect(slide, ctx, x + 5, y + 7, w, 112, "#07446912");
  rect(slide, ctx, x, y, w, 112, C.paper, "#d9dadd", 1);
  await icon(slide, ctx, iconName, x + 20, y + 18, 28, color, 2.2);
  text(slide, ctx, value, x + 62, y + 13, w - 78, 36, {
    size: 32,
    color,
    bold: true,
    face: "Aptos Display",
  });
  text(slide, ctx, label, x + 20, y + 58, w - 40, 18, {
    size: 14,
    color: C.ink,
    bold: true,
  });
  text(slide, ctx, note, x + 20, y + 80, w - 40, 24, {
    size: 11.5,
    color: C.muted,
  });
}

async function feature(slide, ctx, x, y, w, iconName, title, body, color = C.primary) {
  rect(slide, ctx, x, y, w, 88, C.paper, "#d9dadd", 1);
  rect(slide, ctx, x, y, 5, 88, color);
  await icon(slide, ctx, iconName, x + 18, y + 18, 26, color, 2.3);
  text(slide, ctx, title, x + 56, y + 15, w - 72, 20, {
    size: 15.5,
    color: C.ink,
    bold: true,
  });
  text(slide, ctx, wrapWords(body, 48, 2), x + 56, y + 42, w - 72, 36, {
    size: 12,
    color: C.muted,
  });
}

async function node(slide, ctx, x, y, w, h, title, subtitle, iconName, color = C.primary, fill = C.paper) {
  rect(slide, ctx, x, y, w, h, fill, "#c1c7cf", 1.2);
  rect(slide, ctx, x, y, 5, h, color);
  await icon(slide, ctx, iconName, x + 16, y + 18, 28, color, 2.2);
  text(slide, ctx, title, x + 56, y + 14, w - 68, 26, { size: 14.5, color: C.ink, bold: true });
  text(slide, ctx, subtitle, x + 56, y + 43, w - 68, h - 48, { size: 10.8, color: C.muted });
}

async function arrow(slide, ctx, x, y, w, color = C.primary2) {
  rule(slide, ctx, x, y + 13, w - 22, color, 3);
  await icon(slide, ctx, "ArrowRight", x + w - 29, y + 1, 26, color, 2.4);
}

function weightBar(slide, ctx, x, y, label, value, color) {
  const maxW = 215;
  text(slide, ctx, label, x, y, 170, 20, { size: 12.2, color: C.ink, bold: true });
  rect(slide, ctx, x + 178, y + 5, maxW, 10, "#e2e2e6");
  rect(slide, ctx, x + 178, y + 5, maxW * value, 10, color);
  text(slide, ctx, `${Math.round(value * 100)}%`, x + 404, y - 1, 44, 20, {
    size: 12,
    color,
    bold: true,
    align: "right",
  });
}

async function phone(slide, ctx, file, x, y, w, label, color) {
  const h = w * 2.165;
  rect(slide, ctx, x + 12, y + 18, w, h, "#001d3220");
  rect(slide, ctx, x, y, w, h, "#061e2c", "#061e2c", 1.4);
  rect(slide, ctx, x + 11, y + 15, w - 22, h - 30, "#f9f9fd");
  await ctx.addImage(slide, {
    path: `${ctx.assetDir}/${file}`,
    x: x + 11,
    y: y + 15,
    w: w - 22,
    h: h - 30,
    fit: "cover",
    alt: label,
  });
  rect(slide, ctx, x + w * 0.36, y + 8, w * 0.28, 5, "#d9dadd");
  rect(slide, ctx, x + 8, y + h + 12, w - 16, 34, color);
  text(slide, ctx, label, x + 12, y + h + 19, w - 24, 22, {
    size: 10.7,
    color: "#ffffff",
    bold: true,
    align: "center",
  });
}

function miniBar(slide, ctx, x, y, label, value, max, color, maxH = 58) {
  text(slide, ctx, label, x, y, 34, 14, { size: 9.7, color: C.muted, bold: true, align: "right" });
  const h = maxH * (value / max);
  rect(slide, ctx, x + 43, y + 66 - h, 24, h, color);
  text(slide, ctx, String(value), x + 34, y + 72, 42, 14, { size: 9.2, color: C.muted, align: "center" });
}

async function smallStat(slide, ctx, x, y, w, value, label, note, color, iconName) {
  rect(slide, ctx, x, y, w, 78, "#f9f9fd", "#d9dadd", 1);
  await icon(slide, ctx, iconName, x + 11, y + 16, 22, color, 2.2);
  text(slide, ctx, value, x + 39, y + 14, w - 46, 28, {
    size: value.length > 3 ? 20 : 27,
    color,
    bold: true,
    face: "Aptos Display",
  });
  text(slide, ctx, label, x + 14, y + 45, w - 28, 15, { size: 11.2, color: C.ink, bold: true });
  text(slide, ctx, note, x + 14, y + 61, w - 28, 13, { size: 8.8, color: C.muted });
}

async function buildArchitecture(slide, ctx) {
  text(slide, ctx, "SYSTEM WORKFLOW", 590, 258, 220, 18, { size: 13, color: C.primary, bold: true });
  text(slide, ctx, "Trust is built into the data path, not just the interface.", 590, 285, 680, 38, {
    size: 26,
    color: C.ink,
    bold: true,
    face: "Aptos Display",
  });

  const y1 = 355;
  await node(slide, ctx, 590, y1, 190, 82, "Patient App", "search, bookmark, review", "Smartphone", C.primary);
  await arrow(slide, ctx, 793, y1 + 26, 72, C.primary2);
  await node(slide, ctx, 875, y1, 212, 82, "Auth + Role Gate", "patient / provider / admin", "UserRoundCheck", C.teal);
  await arrow(slide, ctx, 1100, y1 + 26, 72, C.primary2);
  await node(slide, ctx, 1182, y1, 246, 82, "Firestore Writes", "users, providers, reviews, community_*", "Database", C.primary2);

  const y2 = 475;
  await node(slide, ctx, 590, y2, 242, 86, "Structured Review", "overall rating + four service-quality criteria", "ClipboardCheck", C.amberDark);
  await arrow(slide, ctx, 846, y2 + 28, 74, C.primary2);
  await node(slide, ctx, 930, y2, 226, 86, "Cloud Function", "recalculateProviderStats on review writes", "Cloud", C.primary);
  await arrow(slide, ctx, 1168, y2 + 28, 50, C.primary2);
  await node(slide, ctx, 1228, y2, 200, 86, "Ranked Listing", "rankingScore drives discovery", "TrendingUp", C.teal);

  const y3 = 596;
  await node(slide, ctx, 590, y3, 250, 78, "Rules Lock Scores", "clients cannot edit averageRating, totalReviews, rankingScore", "ShieldCheck", C.primary);
  await node(slide, ctx, 862, y3, 250, 78, "Provider Replies", "only providerReply + providerReplyAt may update reviews", "MessageSquareReply", C.teal);
  await node(slide, ctx, 1134, y3, 294, 78, "Community Transaction", "off-app doctor aggregate + review write happen atomically", "Hospital", C.amberDark);

  rule(slide, ctx, 590, 698, 838, "#d9dadd", 1);
}

function buildRanking(slide, ctx) {
  rect(slide, ctx, 590, 720, 408, 222, C.paper, "#d9dadd", 1);
  text(slide, ctx, "AHP-INSPIRED RANKING", 614, 744, 220, 16, { size: 12, color: C.teal, bold: true });
  text(slide, ctx, "rankingScore = 0.4 * averageOverallRating + 0.6 * weightedQuestionnaireScore", 614, 771, 352, 40, {
    size: 14.5,
    color: C.ink,
    bold: true,
  });
  weightBar(slide, ctx, 614, 838, "Staff communication", 0.35, C.primary);
  weightBar(slide, ctx, 614, 869, "Hygiene", 0.25, C.teal);
  weightBar(slide, ctx, 614, 900, "Service quality", 0.25, C.teal);
  weightBar(slide, ctx, 614, 931, "Waiting time", 0.15, C.amberDark);
}

async function buildEvidence(slide, ctx) {
  rect(slide, ctx, 1024, 720, 404, 222, C.paper, "#d9dadd", 1);
  text(slide, ctx, "VALIDATION", 1048, 744, 120, 16, { size: 12, color: C.primary, bold: true });
  await smallStat(slide, ctx, 1048, 771, 108, "154", "Dart tests", "unit/widget/A-B", C.primary, "FlaskConical");
  await smallStat(slide, ctx, 1170, 771, 96, "2", "JS tests", "aggregation fn", C.teal, "FileCheck2");
  await smallStat(slide, ctx, 1280, 771, 124, "78.1%", "coverage", "~92% effective", C.amberDark, "Gauge");
  text(slide, ctx, "SUS participant scores", 1050, 862, 170, 18, { size: 12, color: C.muted, bold: true });
  const scores = [90, 72.5, 85, 97.5, 52.5, 75];
  const labels = ["P1", "P2", "P3", "P4", "P5", "P6"];
  scores.forEach((score, i) => miniBar(slide, ctx, 1054 + i * 37, 882, labels[i], Math.round(score), 100, i === 4 ? C.red : i % 2 ? C.teal : C.primary, 54));
  text(slide, ctx, "Mean SUS 78.75 (B - Good)\n86.7% task completion\n6 participants", 1292, 864, 112, 66, {
    size: 10.8,
    color: C.ink,
    bold: true,
  });
}

async function buildRightRail(slide, ctx) {
  text(slide, ctx, "PRODUCT SURFACES", 1464, 70, 220, 18, { size: 13, color: C.primary, bold: true });
  text(slide, ctx, "A real mobile flow, not just a rating formula.", 1464, 98, 360, 54, {
    size: 28,
    color: C.ink,
    bold: true,
    face: "Aptos Display",
  });

  await phone(slide, ctx, "phone_provider_dashboard.png", 1534, 392, 140, "Provider dashboard", C.amberDark);
  await phone(slide, ctx, "phone_home.png", 1460, 176, 150, "Patient discovery", C.primary);
  await phone(slide, ctx, "phone_questionnaire.png", 1626, 218, 150, "Structured review", C.teal);

  await feature(slide, ctx, 1462, 716, 372, "Search", "Patient journey", "Find doctors/pharmacies, compare ranked listings, read reviews, and save providers.", C.primary);
  await feature(slide, ctx, 1462, 816, 372, "UserCog", "Provider + admin control", "Providers reply and request practice changes; admins approve live listing updates.", C.teal);
  await feature(slide, ctx, 1462, 916, 372, "BookOpenCheck", "Honest next sprint", "Improve search affordance and bookmark labels; add emulator-backed integration coverage.", C.amberDark);
}

async function buildLeftRail(slide, ctx) {
  rect(slide, ctx, 0, 0, 540, 1080, C.dark);
  rect(slide, ctx, 0, 0, 18, 1080, C.teal);
  rect(slide, ctx, 58, 64, 72, 72, "#ffffff12", "#91f0ec66", 1.2);
  await icon(slide, ctx, "HeartPulse", 78, 83, 34, C.tealSoft, 2.4);

  text(slide, ctx, "CMPE/ISE/SE 494 GRADUATION PROJECT", 150, 68, 320, 18, { size: 13, color: C.tealSoft, bold: true });
  text(slide, ctx, "Spring 2025-26", 150, 94, 210, 18, { size: 13, color: "#ffffffcc" });

  text(slide, ctx, "DRAPO", 58, 178, 430, 88, {
    size: 84,
    color: "#ffffff",
    bold: true,
    face: "Aptos Display",
  });
  text(slide, ctx, "Patient-Centric\nHealthcare Review Platform", 62, 274, 410, 104, {
    size: 37,
    color: "#ffffff",
    bold: true,
    face: "Aptos Display",
  });
  text(
    slide,
    ctx,
    "A Flutter + Firebase mobile application that turns post-visit feedback into structured provider discovery, role-aware workflows, and server-side weighted rankings.",
    64,
    408,
    405,
    96,
    { size: 18.5, color: "#e2f4ff" },
  );

  text(slide, ctx, "Built for", 64, 540, 90, 16, { size: 12.5, color: C.tealSoft, bold: true });
  text(slide, ctx, "Patients in Turkey seeking reliable healthcare care, plus doctors, pharmacies, and admins who need governed reputation workflows.", 64, 566, 398, 58, {
    size: 15,
    color: "#ffffffd8",
  });

  chip(slide, ctx, "Flutter 3.19+", 64, 650, 122, "#ffffff", "#ffffff10");
  chip(slide, ctx, "Firebase Auth", 198, 650, 132, "#ffffff", "#ffffff10");
  chip(slide, ctx, "Firestore", 342, 650, 98, "#ffffff", "#ffffff10");
  chip(slide, ctx, "Cloud Functions v2", 64, 694, 172, "#ffffff", "#ffffff10");
  chip(slide, ctx, "Provider state", 248, 694, 132, "#ffffff", "#ffffff10");

  rule(slide, ctx, 64, 778, 402, "#91f0ec66", 1);
  text(slide, ctx, "8541", 64, 816, 120, 44, { size: 40, color: C.tealSoft, bold: true, face: "Aptos Display" });
  text(slide, ctx, "Dart lines in lib/", 64, 865, 160, 18, { size: 13, color: "#ffffffd8", bold: true });
  text(slide, ctx, "52", 232, 816, 70, 44, { size: 40, color: C.amber, bold: true, face: "Aptos Display" });
  text(slide, ctx, "Dart source files", 232, 865, 150, 18, { size: 13, color: "#ffffffd8", bold: true });
  text(slide, ctx, "5", 392, 816, 52, 44, { size: 40, color: "#ffffff", bold: true, face: "Aptos Display" });
  text(slide, ctx, "Firestore collections", 392, 865, 130, 32, { size: 13, color: "#ffffffd8", bold: true });

  text(slide, ctx, "No production usage or clinical claims are asserted; this poster presents the repository build and its measured evaluation artifacts.", 64, 990, 402, 38, {
    size: 11.5,
    color: "#ffffffa8",
  });
}

async function buildMainClaim(slide, ctx) {
  text(slide, ctx, "DESIGN CHALLENGE", 590, 70, 170, 18, { size: 13, color: C.teal, bold: true });
  text(slide, ctx, "Healthcare reviews are useful only when the score is hard to fake and easy to understand.", 590, 101, 810, 76, {
    size: 38,
    color: C.ink,
    bold: true,
    face: "Aptos Display",
  });
  rect(slide, ctx, 590, 198, 255, 38, "#ffdad6", "#ffdad6", 1);
  text(slide, ctx, "Problem: single-star ratings flatten service quality and invite weak trust signals.", 606, 207, 225, 18, {
    size: 12.5,
    color: "#93000a",
    bold: true,
  });
  rect(slide, ctx, 862, 198, 276, 38, "#cde5ff", "#cde5ff", 1);
  text(slide, ctx, "Method: structure reviews, enforce one-review IDs, aggregate scores server-side.", 878, 207, 244, 18, {
    size: 12.5,
    color: C.primary,
    bold: true,
  });
  rect(slide, ctx, 1155, 198, 273, 38, "#91f0ec", "#91f0ec", 1);
  text(slide, ctx, "Outcome: ranked discovery plus patient, provider, admin, and community flows.", 1171, 207, 240, 18, {
    size: 12.5,
    color: C.teal,
    bold: true,
  });
}

export async function slide01(presentation, ctx) {
  const slide = presentation.slides.add();
  rect(slide, ctx, 0, 0, 1920, 1080, C.bg);

  for (let x = 560; x < 1880; x += 80) rule(slide, ctx, x, 0, 1, "#e7e8eb", 1_080);
  for (let y = 60; y < 1040; y += 80) rule(slide, ctx, 540, y, 1380, "#edeef1", 1);
  ellipse(slide, ctx, 1338, 58, 340, 340, "#cde5ff55");
  ellipse(slide, ctx, 1540, 720, 260, 260, "#91f0ec55");

  await buildLeftRail(slide, ctx);
  await buildMainClaim(slide, ctx);
  await buildArchitecture(slide, ctx);
  buildRanking(slide, ctx);
  await buildEvidence(slide, ctx);
  await buildRightRail(slide, ctx);

  rule(slide, ctx, 590, 1002, 1244, "#c1c7cf", 1);
  text(
    slide,
    ctx,
    "Sources: README.md, PRODUCT.md, DESIGN.md, TEST_REPORT.md, USABILITY_TEST.md, STUDY_GUIDE.md, functions/src/aggregation.js, firestore.rules, lib/services/firestore_service.dart",
    590,
    1026,
    1244,
    20,
    { size: 10.5, color: C.muted },
  );

  return slide;
}
