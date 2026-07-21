return {
  {
    "keaising/im-select.nvim",
    event = "VeryLazy",
    opts = {
      default_command = "im-select",
      -- 英字入力に使う入力ソース (ABC レイアウト)
      default_im_select = "com.apple.keylayout.ABC",
      -- 起動時・フォーカス取得時・挿入モード離脱時に英字へ戻す
      set_default_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
      -- 挿入モード再突入時は直前の入力ソース (日本語など) を復元する
      set_previous_events = { "InsertEnter" },
    },
  },
}
