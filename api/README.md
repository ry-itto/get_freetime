# API版
## 現状
- カレンダー IDなどが決め打ち
- １ユーザしか対応できていない

## リクエスト
### 空き時間取得
指定した日時の間の空き時間を取得

#### POST `api/v1/freetime/get`
#### パラメータ
- start_date: yyyy/MM/dd 形式
- end_date: yyyy/MM/dd 形式
- start_time: HH:mm 形式
- end_time: HH:mm 形式
- interval_time: HH:mm 形式
