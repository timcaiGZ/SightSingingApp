"use client"

import { 
  User, 
  ChevronRight, 
  Music, 
  Bell, 
  BarChart3,
  Moon,
  Volume2,
  HelpCircle,
  Shield,
} from "lucide-react"
import { useSettings } from "@/lib/settings-context"

interface ProfileTabProps {
  onSettingSelect?: (settingId: string) => void
}

export default function ProfileTab({ onSettingSelect }: ProfileTabProps) {
  const { notationType, setNotationType, darkMode, setDarkMode } = useSettings()

  return (
    <div className="px-4 py-4 space-y-4">
      <h2 className="text-[28px] font-bold text-foreground px-1">我的</h2>

      {/* 用户信息卡片 */}
      <div className="bg-card rounded-2xl p-4 border border-border">
        <div className="flex items-center gap-4">
          <div className="w-16 h-16 bg-accent/20 rounded-full flex items-center justify-center">
            <User className="w-8 h-8 text-accent" />
          </div>
          <div className="flex-1">
            <h3 className="text-[17px] font-semibold text-foreground">吉他学习者</h3>
            <p className="text-[13px] text-muted-foreground">已练习 128 天</p>
          </div>
        </div>
      </div>

      {/* 学习统计 */}
      <div className="bg-card rounded-2xl border border-border overflow-hidden">
        <div className="px-4 py-3 border-b border-border">
          <h3 className="text-[15px] font-semibold text-foreground">学习统计</h3>
        </div>
        <div className="grid grid-cols-2 divide-x divide-border">
          <div className="p-4 text-center">
            <p className="text-[28px] font-bold text-accent">256</p>
            <p className="text-[13px] text-muted-foreground">练习次数</p>
          </div>
          <div className="p-4 text-center">
            <p className="text-[28px] font-bold text-success">78%</p>
            <p className="text-[13px] text-muted-foreground">平均准确率</p>
          </div>
        </div>
        <div className="grid grid-cols-2 divide-x divide-border border-t border-border">
          <div className="p-4 text-center">
            <p className="text-[28px] font-bold text-warning">42</p>
            <p className="text-[13px] text-muted-foreground">小时</p>
          </div>
          <div className="p-4 text-center">
            <p className="text-[28px] font-bold text-module-interval">15</p>
            <p className="text-[13px] text-muted-foreground">连续天数</p>
          </div>
        </div>
      </div>

      {/* 学习设置 */}
      <div className="bg-card rounded-2xl border border-border overflow-hidden">
        <div className="px-4 py-3 border-b border-border">
          <h3 className="text-[15px] font-semibold text-foreground">学习设置</h3>
        </div>
        <div className="divide-y divide-border">
          {/* 谱式选择 */}
          <div className="px-4 py-3">
            <div className="flex items-center gap-3 mb-3">
              <Music className="w-5 h-5 text-accent" />
              <div>
                <p className="text-[15px] text-foreground">谱式选择</p>
                <p className="text-[13px] text-muted-foreground">选择练习时显示的谱式类型</p>
              </div>
            </div>
            <div className="space-y-2 ml-8">
              <button
                onClick={() => setNotationType("staff")}
                className={`w-full flex items-center justify-between px-4 py-3 rounded-xl border ${
                  notationType === "staff"
                    ? "border-accent bg-accent/5"
                    : "border-border"
                }`}
              >
                <div>
                  <p className="text-[15px] text-foreground">五线谱</p>
                  <p className="text-[13px] text-muted-foreground">专业视唱练耳训练</p>
                </div>
                <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${
                  notationType === "staff" ? "border-accent" : "border-muted-foreground"
                }`}>
                  {notationType === "staff" && (
                    <div className="w-2.5 h-2.5 bg-accent rounded-full" />
                  )}
                </div>
              </button>
              <button
                onClick={() => setNotationType("tabSolfege")}
                className={`w-full flex items-center justify-between px-4 py-3 rounded-xl border ${
                  notationType === "tabSolfege"
                    ? "border-accent bg-accent/5"
                    : "border-border"
                }`}
              >
                <div>
                  <p className="text-[15px] text-foreground">六线谱 + 简谱</p>
                  <p className="text-[13px] text-muted-foreground">吉他弹唱学习（推荐）</p>
                </div>
                <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${
                  notationType === "tabSolfege" ? "border-accent" : "border-muted-foreground"
                }`}>
                  {notationType === "tabSolfege" && (
                    <div className="w-2.5 h-2.5 bg-accent rounded-full" />
                  )}
                </div>
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* 通用设置 */}
      <div className="bg-card rounded-2xl border border-border overflow-hidden">
        <div className="px-4 py-3 border-b border-border">
          <h3 className="text-[15px] font-semibold text-foreground">通用设置</h3>
        </div>
        <div className="divide-y divide-border">
          <button
            onClick={() => onSettingSelect?.("audio")}
            className="w-full flex items-center justify-between px-4 py-3 ios-press"
          >
            <div className="flex items-center gap-3">
              <Volume2 className="w-5 h-5 text-accent" />
              <span className="text-[15px] text-foreground">音频设置</span>
            </div>
            <ChevronRight className="w-5 h-5 text-muted-foreground/50" />
          </button>

          <button
            onClick={() => onSettingSelect?.("reminder")}
            className="w-full flex items-center justify-between px-4 py-3 ios-press"
          >
            <div className="flex items-center gap-3">
              <Bell className="w-5 h-5 text-accent" />
              <span className="text-[15px] text-foreground">每日提醒</span>
            </div>
            <ChevronRight className="w-5 h-5 text-muted-foreground/50" />
          </button>

          <button
            onClick={() => onSettingSelect?.("stats")}
            className="w-full flex items-center justify-between px-4 py-3 ios-press"
          >
            <div className="flex items-center gap-3">
              <BarChart3 className="w-5 h-5 text-accent" />
              <span className="text-[15px] text-foreground">学习数据</span>
            </div>
            <ChevronRight className="w-5 h-5 text-muted-foreground/50" />
          </button>

          <div className="flex items-center justify-between px-4 py-3">
            <div className="flex items-center gap-3">
              <Moon className="w-5 h-5 text-accent" />
              <span className="text-[15px] text-foreground">深色模式</span>
            </div>
            <button
              onClick={() => setDarkMode(!darkMode)}
              className={`w-[51px] h-[31px] rounded-full p-0.5 transition-colors ${
                darkMode ? "bg-accent" : "bg-muted"
              }`}
            >
              <div className={`w-[27px] h-[27px] rounded-full bg-white shadow transition-transform ${
                darkMode ? "translate-x-5" : "translate-x-0"
              }`} />
            </button>
          </div>
        </div>
      </div>

      {/* 其他 */}
      <div className="bg-card rounded-2xl border border-border overflow-hidden">
        <div className="divide-y divide-border">
          <button
            onClick={() => onSettingSelect?.("help")}
            className="w-full flex items-center justify-between px-4 py-3 ios-press"
          >
            <div className="flex items-center gap-3">
              <HelpCircle className="w-5 h-5 text-muted-foreground" />
              <span className="text-[15px] text-foreground">帮助与反馈</span>
            </div>
            <ChevronRight className="w-5 h-5 text-muted-foreground/50" />
          </button>

          <button
            onClick={() => onSettingSelect?.("privacy")}
            className="w-full flex items-center justify-between px-4 py-3 ios-press"
          >
            <div className="flex items-center gap-3">
              <Shield className="w-5 h-5 text-muted-foreground" />
              <span className="text-[15px] text-foreground">隐私政策</span>
            </div>
            <ChevronRight className="w-5 h-5 text-muted-foreground/50" />
          </button>
        </div>
      </div>

      {/* 版本信息 */}
      <p className="text-center text-[13px] text-muted-foreground py-4">
        视唱练耳 v2.0.0
      </p>
    </div>
  )
}
