#!/bin/bash
find /Users/pasindutharaka/.gemini/antigravity/scratch/SentinelGuardX/Sources/SentinelGuardX/Views -type f -name "*.swift" | xargs sed -i '' -e 's/\.glassEffect(/.liquidGlassEffect(/g'
find /Users/pasindutharaka/.gemini/antigravity/scratch/SentinelGuardX/Sources/SentinelGuardX/Views -type f -name "*.swift" | xargs sed -i '' -e 's/\.buttonStyle(\.glass)/\.buttonStyle(LiquidGlassButtonStyle())/g'
find /Users/pasindutharaka/.gemini/antigravity/scratch/SentinelGuardX/Sources/SentinelGuardX/Views -type f -name "*.swift" | xargs sed -i '' -e 's/\.buttonStyle(\.glassProminent)/\.buttonStyle(LiquidGlassProminentButtonStyle())/g'
find /Users/pasindutharaka/.gemini/antigravity/scratch/SentinelGuardX/Sources/SentinelGuardX/Views -type f -name "*.swift" | xargs sed -i '' -e 's/GlassEffectContainer/VStack/g'
find /Users/pasindutharaka/.gemini/antigravity/scratch/SentinelGuardX/Sources/SentinelGuardX/Views -type f -name "*.swift" | xargs sed -i '' -e 's/\.glassEffectID(/\.matchedGeometryEffect(id: /g'
