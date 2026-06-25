# Mục đích dự án và hướng dẫn test chức năng

## 1. Mục đích dự án

**Journal Trend Analyzer** là ứng dụng Flutter dùng để phân tích xu hướng nghiên cứu khoa học theo một chủ đề do người dùng nhập.

Ứng dụng gọi trực tiếp OpenAlex API từ mobile client, không dùng backend riêng, không có đăng nhập, phân quyền hoặc cơ sở dữ liệu nội bộ.

Mục tiêu chính:

- Cho phép người dùng tìm kiếm bài báo nghiên cứu theo topic.
- Hiển thị danh sách publication liên quan từ OpenAlex.
- Xem chi tiết từng publication: tác giả, năm xuất bản, journal/source, citation count, DOI, OpenAlex link, publisher link và abstract nếu có.
- Phân tích xu hướng số lượng publication theo năm.
- Hiển thị top influential papers theo citation count.
- Hiển thị top journals và top authors theo dữ liệu group từ OpenAlex.
- Cung cấp dashboard tổng quan về số lượng publication, citation trung bình, năm hoạt động mạnh nhất, journal/author nổi bật và paper ảnh hưởng nhất.

## 2. Các chức năng chính cần test

### 2.1. Khởi động ứng dụng

Mục đích: kiểm tra app render được shell chính.

Kỳ vọng:

- App mở thành công.
- App bar hiển thị `Journal Trend Analyzer`.
- Bottom navigation có 3 tab:
  - `Search`
  - `Trends`
  - `Dashboard`
- Màn hình Search có input `Research topic`.

### 2.2. Tìm kiếm research topic

Mục đích: kiểm tra luồng gọi OpenAlex và hiển thị kết quả.

Cách test thủ công:

1. Mở app.
2. Ở tab `Search`, nhập topic, ví dụ:
   - `machine learning`
   - `climate change`
   - `cancer research`
3. Nhấn nút search hoặc submit từ bàn phím.

Kỳ vọng:

- Loading indicator xuất hiện trong lúc gọi API.
- Sau khi tải xong, danh sách publications xuất hiện.
- Mỗi publication card hiển thị tối thiểu:
  - title
  - year
  - citation count
  - journal/source
  - authors nếu có
- Nếu có nhiều hơn số item đang hiển thị, nút `Load More` xuất hiện.

### 2.3. Input rỗng hoặc không hợp lệ

Mục đích: kiểm tra app không gọi API khi topic rỗng.

Cách test thủ công:

1. Xóa nội dung ô `Research topic`.
2. Nhấn search.

Kỳ vọng:

- App không crash.
- Không gửi request search rỗng.
- Không hiển thị dữ liệu cũ như thể đó là kết quả mới.

### 2.4. Load more publications

Mục đích: kiểm tra phân trang UI nội bộ.

Cách test thủ công:

1. Search một topic có nhiều kết quả, ví dụ `machine learning`.
2. Cuộn xuống cuối danh sách.
3. Nhấn `Load More`.

Kỳ vọng:

- Số publication hiển thị tăng thêm.
- App không giật, không reset về trạng thái lỗi.
- Nút `Load More` biến mất khi đã hiển thị hết kết quả đã load.

### 2.5. Publication detail

Mục đích: kiểm tra điều hướng và thông tin chi tiết publication.

Cách test thủ công:

1. Search topic bất kỳ có kết quả.
2. Nhấn vào một publication card.

Kỳ vọng:

- App chuyển sang màn hình `Publication Details`.
- Hiển thị title, year, citation count, journal/source.
- Hiển thị authors.
- Nếu authors nhiều hơn 5, có nút `Show more`.
- Nếu abstract dài, có nút `Show more` / `Show less`.
- Section `External Links` hiển thị DOI/OpenAlex/Publisher page nếu dữ liệu có sẵn.

### 2.6. Mở external links

Mục đích: kiểm tra link DOI/OpenAlex/Publisher page.

Cách test thủ công:

1. Vào màn hình publication detail.
2. Nhấn link DOI, OpenAlex hoặc Publisher page nếu có.

Kỳ vọng:

- Link mở bằng external browser/app.
- Nếu không mở được link, app hiển thị snackbar `Unable to open link.`
- App không crash khi URL thiếu hoặc không hợp lệ.

### 2.7. Trend Analysis tab

Mục đích: kiểm tra dữ liệu phân tích xu hướng.

Cách test thủ công:

1. Search một topic ở tab `Search`.
2. Chuyển sang tab `Trends`.

Kỳ vọng:

- Khi chưa có dữ liệu, tab hiển thị empty state `No trend data`.
- Sau khi search thành công, tab hiển thị:
  - `Publication Trend`
  - chart theo năm
  - `Top Influential Papers`
  - `Top Research Journals`
  - `Top Contributing Authors`
- Nếu dữ liệu phụ từ OpenAlex thiếu hoặc lỗi một phần, app vẫn không crash.

### 2.8. Dashboard tab

Mục đích: kiểm tra dashboard tổng quan.

Cách test thủ công:

1. Search topic thành công.
2. Chuyển sang tab `Dashboard`.

Kỳ vọng:

- Khi chưa có dữ liệu, hiển thị empty state `No dashboard data`.
- Sau khi có dữ liệu, dashboard hiển thị:
  - total publications
  - average citations
  - peak year
  - most influential paper
  - top journal
  - top author
  - snapshot số lượng dữ liệu đã load

### 2.9. Refresh dữ liệu

Mục đích: kiểm tra nút refresh trên app bar.

Cách test thủ công:

1. Search topic thành công.
2. Nhấn nút refresh trên app bar.

Kỳ vọng:

- App gọi lại search với topic hiện tại.
- Loading indicator xuất hiện.
- Dữ liệu được cập nhật lại.
- Nếu chưa từng search topic nào, refresh không gây lỗi.

### 2.10. Network/API error

Mục đích: kiểm tra xử lý lỗi mạng/API.

Cách test thủ công:

1. Tắt internet trên thiết bị/emulator.
2. Search topic bất kỳ.

Kỳ vọng:

- App không crash.
- Hiển thị error panel với thông báo lỗi.
- Nếu có topic hiện tại, nút `Retry` xuất hiện.
- Khi bật mạng lại và nhấn `Retry`, app có thể tải lại dữ liệu.

## 3. Cách chạy app để test thủ công

### 3.1. Cài dependencies

```bash
flutter pub get
```

### 3.2. Chạy trên thiết bị/emulator

```bash
flutter run -d <android-device-id>
```

Ví dụ nếu chỉ có một emulator/device:

```bash
flutter run
```

### 3.3. Chạy với OpenAlex API key

OpenAlex có thể dùng không cần API key cho test nhẹ. Nếu cần dùng key:

```bash
flutter run -d <android-device-id> --dart-define=OPENALEX_API_KEY=your_key
```

## 4. Cách chạy test tự động

### 4.1. Format code

```bash
dart format lib test
```

Kỳ vọng:

- Dart formatter chạy thành công.
- Không có file Dart format lỗi.

### 4.2. Static analysis

```bash
flutter analyze
```

Kỳ vọng:

- Kết quả: `No issues found!`

### 4.3. Widget test hiện có

```bash
flutter test
```

Kỳ vọng:

- Test `renders the journal trend analyzer shell` pass.
- Test xác nhận app render được title, search input và bottom navigation.

### 4.4. Android debug build

```bash
flutter build apk --debug
```

Kỳ vọng:

- Build thành công.
- File APK debug được tạo tại:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## 5. Checklist test trước khi nộp

- [ ] `flutter pub get` chạy thành công.
- [ ] `dart format lib test` chạy thành công.
- [ ] `flutter analyze` không có issue.
- [ ] `flutter test` pass.
- [ ] `flutter build apk --debug` pass.
- [ ] App mở được trên emulator/device.
- [ ] Search topic thành công và hiển thị danh sách publications.
- [ ] Publication detail mở được và hiển thị đúng thông tin.
- [ ] Link external không làm app crash.
- [ ] Trends tab hiển thị chart và ranking sau khi search.
- [ ] Dashboard tab hiển thị metrics sau khi search.
- [ ] Empty state hiển thị đúng khi chưa có dữ liệu.
- [ ] Error state hiển thị đúng khi mất mạng/API lỗi.
- [ ] Refresh hoạt động với topic hiện tại.

## 6. Ghi chú kỹ thuật

- App dùng `provider` và `ChangeNotifier` để quản lý state.
- API integration nằm ở `lib/services/openalex_service.dart`.
- State chính nằm ở `lib/state/research_controller.dart`.
- Models dữ liệu nằm ở `lib/models/`.
- UI screens nằm ở `lib/screens/`.
- Shared widgets nằm ở `lib/widgets/`.
- App không lưu dữ liệu offline; dữ liệu phụ thuộc OpenAlex response tại thời điểm test.
- Một số kết quả test thủ công có thể thay đổi theo dữ liệu OpenAlex thực tế.
