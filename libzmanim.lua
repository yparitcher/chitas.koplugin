local ffi = require("ffi")

ffi.cdef[[
typedef struct {
  double latitude;
  double longitude;
  double elevation;
} location;
typedef enum {
  NOPARSHAH = 0,
  BERESHIT = 1,
  NOACH = 2,
  LECH_LECHA = 3,
  VAYEIRA = 4,
  CHAYEI_SARAH = 5,
  TOLEDOT = 6,
  VAYETZE = 7,
  VAYISHLACH = 8,
  VAYESHEV = 9,
  MIKETZ = 10,
  VAYIGASH = 11,
  VAYECHI = 12,
  SHEMOT = 13,
  VAEIRA = 14,
  BO = 15,
  BESHALACH = 16,
  YITRO = 17,
  MISHPATIM = 18,
  TERUMAH = 19,
  TETZAVEH = 20,
  KI_TISA = 21,
  VAYAKHEL = 22,
  PEKUDEI = 23,
  VAYIKRA = 24,
  TZAV = 25,
  SHEMINI = 26,
  TAZRIA = 27,
  METZORA = 28,
  ACHAREI_MOT = 29,
  KEDOSHIM = 30,
  EMOR = 31,
  BEHAR = 32,
  BECHUKOTAI = 33,
  BAMIDBAR = 34,
  NASO = 35,
  BEHAALOTECHA = 36,
  SHLACH = 37,
  KORACH = 38,
  CHUKAT = 39,
  BALAK = 40,
  PINCHAS = 41,
  MATOT = 42,
  MASEI = 43,
  DEVARIM = 44,
  VAETCHANAN = 45,
  EIKEV = 46,
  REEH = 47,
  SHOFTIM = 48,
  KI_TEITZEI = 49,
  KI_TAVO = 50,
  NITZAVIM = 51,
  VAYELECH = 52,
  HAAZINU = 53,
  VZOT_HABERACHAH = 54,
  VAYAKHEL_PEKUDEI = 55,
  TAZRIA_METZORA = 56,
  ACHAREI_MOT_KEDOSHIM = 57,
  BEHAR_BECHUKOTAI = 58,
  CHUKAT_BALAK = 59,
  MATOT_MASEI = 60,
  NITZAVIM_VAYELECH = 61,
} parshah;
typedef enum {
  CHOL = 0,
  PESACH_DAY1 = 1,
  PESACH_DAY2 = 2,
  SHVEI_SHEL_PESACH = 3,
  ACHRON_SHEL_PESACH = 4,
  SHAVOUS_DAY1 = 5,
  SHAVOUS_DAY2 = 6,
  ROSH_HASHANAH_DAY1 = 7,
  ROSH_HASHANAH_DAY2 = 8,
  YOM_KIPPUR = 9,
  SUKKOS_DAY1 = 10,
  SUKKOS_DAY2 = 11,
  SHMEINI_ATZERES = 12,
  SIMCHAS_TORAH = 13,
  CHOL_HAMOED_PESACH_DAY1 = 14,
  CHOL_HAMOED_PESACH_DAY2 = 15,
  CHOL_HAMOED_PESACH_DAY3 = 16,
  CHOL_HAMOED_PESACH_DAY4 = 17,
  CHOL_HAMOED_PESACH_DAY5 = 18,
  CHOL_HAMOED_SUKKOS_DAY1 = 19,
  CHOL_HAMOED_SUKKOS_DAY2 = 20,
  CHOL_HAMOED_SUKKOS_DAY3 = 21,
  CHOL_HAMOED_SUKKOS_DAY4 = 22,
  CHOL_HAMOED_SUKKOS_DAY5 = 23,
  HOSHANA_RABBAH = 24,
  PESACH_SHEINI = 25,
  LAG_BAOMER = 26,
  TU_BAV = 27,
  CHANUKAH_DAY1 = 28,
  CHANUKAH_DAY2 = 29,
  CHANUKAH_DAY3 = 30,
  CHANUKAH_DAY4 = 31,
  CHANUKAH_DAY5 = 32,
  CHANUKAH_DAY6 = 33,
  CHANUKAH_DAY7 = 34,
  CHANUKAH_DAY8 = 35,
  TU_BISHVAT = 36,
  PURIM_KATAN = 37,
  SHUSHAN_PURIM_KATAN = 38,
  PURIM = 39,
  SHUSHAN_PURIM = 40,
  SHIVA_ASAR_BTAAMUZ = 41,
  TISHA_BAV = 42,
  TZOM_GEDALIA = 43,
  ASARAH_BTEVES = 44,
  TAANIS_ESTER = 45,
  EREV_PESACH = 46,
  EREV_SHAVOUS = 47,
  EREV_ROSH_HASHANAH = 48,
  EREV_YOM_KIPPUR = 49,
  EREV_SUKKOS = 50,
  SHKALIM = 51,
  ZACHOR = 52,
  PARAH = 53,
  HACHODESH = 54,
  ROSH_CHODESH = 55,
  MACHAR_CHODESH = 56,
  SHABBOS_MEVORCHIM = 57,
} yomtov;
typedef struct {
  int year;
  int month;
  int day;
  int hour;
  int min;
  int sec;
  int msec;
  int wday;
  int dayofyear;
  long int offset;
  bool leap;
  bool EY;
} hdate;
typedef struct {
  int year;
  int month;
  int day;
  int hour;
  int min;
  int sec;
  int msec;
  int wday;
  int dayofyear;
  long int offset;
  bool leap;
  bool EY;
} molad;
int LastDayOfHebrewMonth(int, int);
int HebrewLeapYear(int);
long int HebrewCalendarElapsedDays(int);
hdate convertDate(struct tm);
void setEY(hdate *, bool);
double hdatejulian(hdate);
struct tm hdategregorian(hdate);
double gregorianjulian(struct tm);
long int hdatetime_t(hdate);
int hdatecompare(hdate, hdate);
void hdateaddyear(hdate *, int);
void hdateaddmonth(hdate *, int);
void hdateaddday(hdate *, int);
void hdateaddhour(hdate *, int);
void hdateaddminute(hdate *, int);
void hdateaddsecond(hdate *, int);
void hdateaddmsecond(hdate *, int);
void hdateadd(hdate *, int, int, int, int, int, int, int);
molad getmolad(int, int);
parshah getparshah(hdate);
yomtov getyomtov(hdate);
yomtov getspecialshabbos(hdate);
yomtov getroshchodesh(hdate);
yomtov getmacharchodesh(hdate);
yomtov getshabbosmevorchim(hdate);
int getomer(hdate);
int getavos(hdate);
bool istaanis(hdate);
bool isassurbemelachah(hdate);
int iscandlelighting(hdate);
bool isbirchashachama(hdate);
bool isbirchashashanim(hdate);
bool getbirchashashanim(hdate);
int chumash(hdate, char *);
int tehillim(hdate, char *);
int tanya(hdate, char *);
int rambam(hdate, char *);
]]
