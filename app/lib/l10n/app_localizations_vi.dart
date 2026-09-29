// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'SCP Reader';

  @override
  String loadError(String error) {
    return 'Không mở được dữ liệu:\n$error';
  }

  @override
  String get navLibrary => 'Thư viện';

  @override
  String get navHistory => 'Lịch sử';

  @override
  String get navSearch => 'Tìm kiếm';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get libraryTitle => 'Thư viện SCP';

  @override
  String get continueReading => 'Đọc tiếp';

  @override
  String get nowReading => 'ĐANG ĐỌC';

  @override
  String get finished => 'Đã đọc xong';

  @override
  String seriesLabel(String roman) {
    return 'Series $roman';
  }

  @override
  String get addSeries => 'Tải thêm series';

  @override
  String readProgress(int read, int total) {
    return '$read/$total đã đọc';
  }

  @override
  String get filterAll => 'Tất cả';

  @override
  String get filterUnread => 'Chưa đọc';

  @override
  String get filterRead => 'Đã đọc';

  @override
  String get noItems => 'Không có bài nào';

  @override
  String get noContentTitle => 'Chưa có gói nội dung';

  @override
  String get noContentBody => 'Tải một series để bắt đầu đọc.';

  @override
  String get downloadPacks => 'Tải gói nội dung';

  @override
  String get statusRead => 'Đã đọc';

  @override
  String get statusUnread => 'Chưa đọc';

  @override
  String markedRead(String code) {
    return 'Đã đánh dấu $code là đã đọc';
  }

  @override
  String unmarkedRead(String code) {
    return 'Đã bỏ đánh dấu $code';
  }

  @override
  String get historyTitle => 'Lịch sử đọc';

  @override
  String get historyEmpty => 'Chưa đọc bài nào';

  @override
  String get justNow => 'vừa xong';

  @override
  String minutesAgo(int n) {
    return '$n phút';
  }

  @override
  String hoursAgo(int n) {
    return '$n giờ';
  }

  @override
  String daysAgo(int n) {
    return '$n ngày';
  }

  @override
  String get searchHint => 'Số hiệu (vd: 173) hoặc tên bài';

  @override
  String get searchPrompt => 'Nhập số hiệu hoặc tên SCP';

  @override
  String get searchNoResult => 'Không tìm thấy';

  @override
  String get sectionGeneral => 'Chung';

  @override
  String get sectionReader => 'Trình đọc';

  @override
  String get sectionData => 'Dữ liệu';

  @override
  String get sectionAbout => 'Giới thiệu';

  @override
  String get appLanguage => 'Ngôn ngữ ứng dụng';

  @override
  String get languageSystem => 'Theo hệ thống';

  @override
  String get preferVietnamese => 'Ưu tiên bản dịch tiếng Việt';

  @override
  String get preferVietnameseSub => 'Tắt để mặc định mở bản gốc tiếng Anh';

  @override
  String get managePacks => 'Quản lý gói nội dung';

  @override
  String packsSummary(int count, int packs) {
    return '$count bài trong $packs series';
  }

  @override
  String readStats(int read, int total) {
    return 'Đã đọc $read / $total bài';
  }

  @override
  String get resetProgress => 'Xóa toàn bộ tiến độ đọc';

  @override
  String get resetConfirmTitle => 'Xóa tiến độ?';

  @override
  String get resetConfirmBody =>
      'Mọi đánh dấu đã đọc và vị trí đọc sẽ bị xóa. Không thể hoàn tác.';

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get translationModel => 'Gói dịch offline';

  @override
  String get translationModelReady => 'Đã tải gói Anh–Việt';

  @override
  String get translationModelMissing =>
      'Chưa tải (~30 MB, tự tải khi dịch lần đầu)';

  @override
  String get translationModelDeleted => 'Đã xóa gói dịch';

  @override
  String get sourceTitle => 'Nguồn: SCP Wiki (scp-wiki.wikidot.com)';

  @override
  String get sourceSubtitle =>
      'Nội dung theo giấy phép CC BY-SA 3.0. Bấm để xem chi tiết.';

  @override
  String get privacyPolicy => 'Chính sách quyền riêng tư';

  @override
  String get fontSize => 'Cỡ chữ';

  @override
  String get lineHeight => 'Giãn dòng';

  @override
  String get background => 'Nền';

  @override
  String get themeDark => 'Tối';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get themeLight => 'Sáng';

  @override
  String get markRead => 'Đánh dấu đã đọc';

  @override
  String get unmarkRead => 'Bỏ đánh dấu đã đọc';

  @override
  String get textSettings => 'Tùy chỉnh chữ';

  @override
  String get noTranslation => 'Chưa có bản dịch';

  @override
  String attributionBy(String author) {
    return ' của $author';
  }

  @override
  String attribution(String code, String by, String url) {
    return '\"$code\"$by, từ SCP Wiki. Nguồn: $url. Giấy phép CC BY-SA 3.0.';
  }

  @override
  String get attributionMlKit =>
      ' Bản tiếng Việt được dịch máy bằng Google ML Kit.';

  @override
  String get attributionAi => ' Bản tiếng Việt được dịch tự động bằng AI.';

  @override
  String get translateTooltip => 'Dịch sang tiếng Việt';

  @override
  String get showOriginal => 'Xem bản gốc';

  @override
  String get translating => 'Đang dịch...';

  @override
  String get translateFailed => 'Không dịch được. Hãy thử lại.';

  @override
  String get modelDownloadTitle => 'Tải gói dịch?';

  @override
  String get modelDownloadBody =>
      'Việc dịch chạy ngay trên máy và cần gói dịch offline Anh–Việt (khoảng 30 MB). Tải ngay bây giờ?';

  @override
  String get download => 'Tải';

  @override
  String get modelDownloadFailed =>
      'Không tải được gói dịch. Hãy kiểm tra kết nối mạng.';

  @override
  String get packsTitle => 'Gói nội dung';

  @override
  String get packsLoadError =>
      'Không tải được danh sách gói trực tuyến. Hãy kiểm tra kết nối mạng.';

  @override
  String get retry => 'Thử lại';

  @override
  String get downloadAll => 'Tải tất cả';

  @override
  String get packInstalled => 'Đã tải';

  @override
  String get packBundled => 'Có sẵn trong app';

  @override
  String get packUpdate => 'Có bản cập nhật';

  @override
  String get packNotInstalled => 'Chưa tải';

  @override
  String packMeta(int count, String size) {
    return '$count bài · $size';
  }

  @override
  String get install => 'Cài';

  @override
  String get update => 'Cập nhật';

  @override
  String get remove => 'Xóa';

  @override
  String packRemoveConfirm(String roman) {
    return 'Xóa Series $roman? Tiến độ đọc vẫn được giữ lại.';
  }

  @override
  String packInstallFailed(String roman) {
    return 'Không cài được Series $roman.';
  }

  @override
  String get licenseTitle => 'Giấy phép';

  @override
  String get licenseIntro =>
      'Các bài viết trong app được lấy từ SCP Wiki (scp-wiki.wikidot.com) và được cấp phép theo Creative Commons Ghi công – Chia sẻ tương tự 3.0 (CC BY-SA 3.0).';

  @override
  String get licenseAttribution =>
      'Cuối mỗi bài đều ghi tên tác giả gốc và đường dẫn tới trang nguồn.';

  @override
  String get licenseShareAlike =>
      'Các bản dịch máy hiển thị trong app là tác phẩm phái sinh và được chia sẻ theo cùng giấy phép CC BY-SA 3.0.';

  @override
  String get licenseImages =>
      'Ảnh minh họa được tải trực tiếp từ SCP Wiki và có thể có giấy phép riêng. Xem trang nguồn của ảnh để biết chi tiết.';

  @override
  String get licenseUnofficial =>
      'Đây là app không chính thức do người hâm mộ làm, không liên kết và không được SCP Wiki hay đội ngũ quản trị của wiki bảo trợ.';

  @override
  String get openLicense => 'Xem giấy phép CC BY-SA 3.0';

  @override
  String get openSourceLicenses => 'Giấy phép thư viện mã nguồn mở';
}
