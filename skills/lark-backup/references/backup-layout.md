# 备份输出布局

## 文档 `docx`

目录下通常会有：

- `meta.json` — Drive 元数据
- `fetch.json` — `docs +fetch` 的完整 JSON
- `content.md` — 从 `fetch.json` 提取出的 Markdown
- `export-markdown.json` — `drive +export --file-extension markdown` 的结果
- `export-pdf.json` — `drive +export --file-extension pdf` 的结果
- 实际导出的 `.md` / `.pdf` 文件

## 旧版文档 `doc`

- `meta.json`
- `export-docx.json`
- `export-pdf.json`
- 实际导出的 `.docx` / `.pdf`

## 电子表格 `sheet`

- `info.json` — `sheets +info`
- `export-xlsx.json`
- `workbook.xlsx`
- `csv/` — 每个工作表一个 `.csv`
- `csv-*.json` — 每个工作表 CSV 导出记录

## 多维表格 `bitable`

- `base.json` — `base +base-get`
- `tables.json` — `base +table-list`
- `snapshot-xlsx.json` — `drive +export` 结果
- `tables/<table_id>/table.json` — `base +table-get`
- `tables/<table_id>/records-page-*.json` — `base +record-list` 分页结果

## 文件夹 `folder`

- `folder-items.json` — 当前文件夹聚合后的清单
- `items/<序号>-<名称>/` — 每个子项一个目录

## 已知边界

1. `docx` 内嵌图片/附件 token 会保留在 `fetch.json` 和 `content.md` 中，但脚本当前**不自动下载每个内嵌素材**。
2. `slides`、`mindnote`、未知对象类型目前只保存 `entry.json` 并写入 `SKIPPED.txt`。
3. `base +record-list` 的返回形状在不同环境可能不同，脚本按较宽松规则分页并把**原始响应完整落盘**，不要假设只有一种 schema。
4. 文件夹递归时会跳过已访问过的 folder token，避免快捷方式或目录环导致无限循环。
