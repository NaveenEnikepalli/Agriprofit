import '../models/fertilizer.dart';

const Map<String, FertilizerInfo> fertilizerData = {
  "Tomato": FertilizerInfo(
    basal: BasalDose(nitrogen: 50, phosphorus: 50, potash: 50),
    topdress: [
      TopDressing(
        daysAfterTransplant: 20,
        nitrogen: 25,
        note: "Apply urea in ring 5-7 cm from stem, light irrigation",
      ),
      TopDressing(
        daysAfterTransplant: 45,
        nitrogen: 25,
        note: "Split dose near root zone, avoid foliar burn; irrigate",
      ),
    ],
  ),
  "Onion": FertilizerInfo(
    basal: BasalDose(nitrogen: 40, phosphorus: 60, potash: 40),
    topdress: [
      TopDressing(
        daysAfterTransplant: 30,
        nitrogen: 20,
        note: "Side-dress N along rows; maintain moist soil",
      ),
      TopDressing(
        daysAfterTransplant: 50,
        nitrogen: 20,
        note: "Apply before bulb enlargement; avoid standing water",
      ),
    ],
  ),
  "Paddy": FertilizerInfo(
    basal: BasalDose(nitrogen: 40, phosphorus: 20, potash: 20),
    topdress: [
      TopDressing(
        daysAfterSowing: 20,
        nitrogen: 20,
        note: "Apply at active tillering; maintain 2-3 cm water level",
      ),
      TopDressing(
        daysAfterSowing: 40,
        nitrogen: 20,
        note: "Apply at panicle initiation; drain and reflood after 24h",
      ),
    ],
  ),
  "Maize": FertilizerInfo(
    basal: BasalDose(nitrogen: 40, phosphorus: 20, potash: 20),
    topdress: [
      TopDressing(
        daysAfterSowing: 25,
        nitrogen: 30,
        note: "Side-dress at knee-high stage; irrigate after application",
      ),
      TopDressing(
        daysAfterSowing: 45,
        nitrogen: 30,
        note: "At tasseling; avoid application on wet foliage",
      ),
    ],
  ),
  "Wheat": FertilizerInfo(
    basal: BasalDose(nitrogen: 40, phosphorus: 20, potash: 0),
    topdress: [
      TopDressing(
        daysAfterSowing: 21,
        nitrogen: 20,
        note: "First irrigation; apply along rows",
      ),
      TopDressing(
        daysAfterSowing: 45,
        nitrogen: 20,
        note: "At crown root initiation; ensure adequate moisture",
      ),
    ],
  ),
  "Groundnut": FertilizerInfo(
    basal: BasalDose(nitrogen: 12, phosphorus: 24, potash: 24),
    topdress: [
      TopDressing(
        daysAfterSowing: 30,
        nitrogen: 10,
        note: "Gypsum at flowering improves pod filling; avoid waterlogging",
      ),
    ],
  ),
  "Cotton": FertilizerInfo(
    basal: BasalDose(nitrogen: 40, phosphorus: 20, potash: 20),
    topdress: [
      TopDressing(
        daysAfterSowing: 30,
        nitrogen: 30,
        note: "Split N; avoid excess to reduce vegetative growth",
      ),
      TopDressing(
        daysAfterSowing: 60,
        nitrogen: 20,
        note: "Apply before flowering; light irrigation",
      ),
    ],
  ),
  "Chillies": FertilizerInfo(
    basal: BasalDose(nitrogen: 30, phosphorus: 30, potash: 30),
    topdress: [
      TopDressing(
        daysAfterTransplant: 25,
        nitrogen: 20,
        note: "Apply around plants; maintain uniform moisture",
      ),
      TopDressing(
        daysAfterTransplant: 45,
        nitrogen: 20,
        note: "Split dose during fruit set; avoid salt injury",
      ),
    ],
  ),
  "Turmeric": FertilizerInfo(
    basal: BasalDose(nitrogen: 25, phosphorus: 20, potash: 30),
    topdress: [
      TopDressing(
        daysAfterSowing: 60,
        nitrogen: 25,
        note: "At 2 months; mulch helps moisture conservation",
      ),
      TopDressing(
        daysAfterSowing: 120,
        nitrogen: 25,
        note: "At 4 months; ensure drainage in heavy rains",
      ),
    ],
  ),
  "Banana": FertilizerInfo(
    basal: BasalDose(nitrogen: 40, phosphorus: 20, potash: 40),
    topdress: [
      TopDressing(
        daysAfterTransplant: 60,
        nitrogen: 40,
        note: "Apply in 4 splits monthly; increase K for fruit quality",
      ),
      TopDressing(
        daysAfterTransplant: 120,
        nitrogen: 40,
        note: "Maintain regular irrigation; avoid fertilizer contact with pseudostem",
      ),
    ],
  ),
};
