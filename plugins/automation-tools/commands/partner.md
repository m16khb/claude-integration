---
name: automation-tools:partner
description: 'AI 파트너 관리 (선택, 상태, 피드백)'
argument-hint: '<action> [options]'
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - AskUserQuestion
  - TodoWrite
model: claude-opus-4-5-20251101
---

# AI Partner Management Command

## MISSION

AI 파트너 시스템을 관리하고 최적의 협업 경험을 제공합니다.

**Usage**: `/partner <action> [options]`

---

## ACTIONS

### 1. select
현재 작업에 가장 적합한 AI 파트너를 선택합니다.

```bash
/partner select                    # 대화형 선택
/partner select --auto            # 자동 매칭
/partner select the-architect     # 특정 파트너 직접 선택
```

### 2. status
현재 파트너십 상태를 확인합니다.

```bash
/partner status                   # 기본 상태
/partner status --detailed        # 상세 정보
/partner status --history         # 협업 기록
```

### 3. feedback
파트너에게 피드백을 제공합니다.

```bash
/partner feedback                 # 대화형 피드백
/partner feedback --rate 4.5      # 평점 제공
/partner feedback --file feedback.txt  # 파일에서 피드백
```

### 4. switch
다른 파트너로 변경합니다.

```bash
/partner switch                   # 파트너 선택창 표시
/partner switch the-pragmatist    # 특정 파트너로 변경
```

### 5. team
파트너 팀을 구성하고 관리합니다.

```bash
/partner team create "Dev Team"   # 새 팀 생성
/partner team add the-mentor      # 팀에 멤버 추가
/partner team list                # 팀 목록
```

### 6. memory
파트너의 컨텍스트 메모리를 관리합니다.

```bash
/partner memory view              # 메모리 확인
/partner memory clear             # 메모리 초기화
/partner memory export            # 메모리 내보내기
```

## PARTNER PROFILES

### Available Partners

1. **The Architect** (🏛️)
   - 전문 분야: 시스템 아키텍처, 설계 패턴
   - 적합한 작업: 복잡한 시스템 설계, 기술 결정

2. **The Pragmatist** (🔧)
   - 전문 분야: 실용적 구현, 빠른 프로토타이핑
   - 적합한 작업: MVP 개발, 즉각적인 문제 해결

3. **The Mentor** (👨‍🏫)
   - 전문 분야: 교육, 코드 리뷰, 베스트 프랙티스
   - 적합한 작업: 학습, 기술 향상, 리팩토링

4. **The Innovator** (💡)
   - 전문 분야: 최신 기술, 실험적 접근
   - 적합한 작업: R&D, 혁신적 솔루션

5. **The Guardian** (🛡️)
   - 전문 분야: 보안, 테스트, 품질 보증
   - 적합한 작업: 코드 리뷰, 보안 감사, QA

## USAGE EXAMPLES

### Selecting a Partner
```bash
$ /partner select

🔍 현재 작업 분석 중...
✅ "React 컴포넌트 개발" task detected
✅ 복잡도: moderate
✅ 사용자 수준: intermediate

🎯 추천 파트너:
1. The Pragmatist (92% 일치) - 빠른 구현에 특화
2. The Mentor (78% 일치) - 학습 지원에 특화
3. The Innovator (65% 일치) - 새로운 접근법 제공

선택 > 1

🤝 The Pragmatist와 파트너십이 시작되었습니다!
```

### Checking Status
```bash
$ /partner status --detailed

🤝 현재 파트너: The Pragmatist
📊 관계 레벨: Trusted Partner (Level 6)
⏱️  협업 시간: 47시간 32분

📈 성과 지표:
├─ 완료된 작업: 89개
├─ 평균 만족도: 4.7/5.0
├─ 반복 작업률: 12%
└─ 성공률: 96%

🎯 강점 분석:
├─ ⚡ 빠른 프로토타이핑 (Expert)
├─ 🎯 문제 해결 (Advanced)
├─ 💡 실용적 솔루션 (Expert)
└─ 📚 문서화 (Intermediate)

🔥 최근 성취:
├─ ✅ 30분 만에 API 엔드포인트 5개 구현
├─ ✅ 성능 저하 원인 2가지 식별 및 수정
└─ 🏆 Efficiency Badge 획득
```

### Providing Feedback
```bash
$ /partner feedback

📝 피드백 제공 (The Pragmatist)

1. 작업 만족도 (1-5): 5
2. 솔루션 품질 (1-5): 4
3. 소통 명확성 (1-5): 5
4. 추가 코멘트:
   "정말 빠르고 실용적인 해결책을 제공해줘서 만족합니다.
    다만 때로는 더 창의적인 접근도 좋을 것 같아요."

✅ 피드백이 기록되었습니다.
🎉 The Pragmatist가 50 XP를 획득했습니다!
📈 파트너와의 관계가 강화되었습니다.
```

## CONFIGURATION

### Partner Preferences
```yaml
# .claude/partner-config.yml
preferences:
  auto_select: true
  learning_mode: false
  feedback_reminder: true

communication:
  style: "friendly"
  detail_level: "balanced"
  examples: true

team:
  enable_collaboration: false
  auto_assemble: false
```

### Partner Customization
```bash
# 파트너 설정 커스터마이징
/partner config the-architect

설정 옵션:
□ Formal communication style
□ Include diagrams automatically
□ Ask clarifying questions
□ Provide alternatives
□ Risk assessment mode
□ Documentation first approach
```

## INTEGRATION

### With Workflow Commands
```bash
# dev-flow와 통합
/dev-flow --partner the-guardian    # 보안 중심 개발
/dev-flow --partner the-mentor     # 학습 중심 개발

# 특정 작업에 파트너 지정
/feature "인증 시스템" --partner the-architect
/refactor "레거시 코드" --partner the-mentor
```

### With Project Management
```bash
# 프로젝트별 파트너 할당
/partner assign --project e-commerce --team fullstack
/partner assign --project mobile-app --partner the-pragmatist
```

## ADVANCED FEATURES

### Partner Training
```bash
# 파트너 학습 데이터 제공
/partner train --file my-coding-style.js
/partner train --project-standards
/partner train --from-feedback feedback.log
```

### Collaborative Mode
```bash
# 여러 파트너와 동시 작업
/partner team create "Dream Team"
/partner team add the-architect --role lead
/partner team add the-pragmatist --role implementer
/partner team add the-guardian --role reviewer

# 팀 작업 시작
/partner team work-on "새로운 기능 개발"
```

### Performance Analytics
```bash
# 파트너 성과 분석
/partner analytics --period week
/partner analytics --by-task-type
/partner analytics --compare partners
```

## BEST PRACTICES

1. **Consistent Partner Usage**
   - 비슷한 작업에는 같은 파트너 활용
   - 파트너의 학습 곡선 고려

2. **Regular Feedback**
   - 매 세션 후 간단한 피드백 제공
   - 구체적인 예시와 함께 제공

3. **Context Sharing**
   - 프로젝트 배경 정보 공유
   - 이전 작업 결과 공유

4. **Relationship Building**
   - 긍정적 강화 regular
   - 장기적 관계 perspective

## TROUBLESHOOTING

### Partner Not Responsive
```bash
# 해결 방법
/partner reset               # 파트너 세션 초기화
/partner memory clear        # 컨텍스트 클리어
/partner switch             # 다른 파트너로 변경
```

### Poor Match
```bash
# 개선 방법
/partner re-evaluate        # 재평가 요청
/partner feedback --negative # 부정적 피드백
/partner config             # 설정 조정
```

## STATS AND ACHIEVEMENTS

### Relationship Levels
1. **New Partner** (0-100 XP)
2. **Getting Familiar** (100-500 XP)
3. **Working Partner** (500-1500 XP)
4. **Trusted Partner** (1500-5000 XP)
5. **Expert Collaborator** (5000+ XP)

### Badges
- 🏆 **Speed Demon** - 10개 작업을 평균 시간 미만으로 완료
- 💎 **Quality Master** - 연속 20개 5점 리뷰
- 🎯 **Problem Solver** - 100개 복잡한 문제 해결
- 👥 **Team Player** - 성공적인 팀 프로젝트 10회
- 📚 **Knowledge Sharer** - 50개 베스트 프랙티스 공유

---

## QUICK REFERENCE

```bash
# 기본 명령어
/partner select              # 파트너 선택
/partner status              # 상태 확인
/partner feedback            # 피드백 제공
/partner switch              # 파트너 변경

# 고급 명령어
/partner team <action>       # 팀 관리
/partner memory <action>     # 메모리 관리
/partner config <partner>    # 설정 변경
/partner analytics           # 성과 분석

# 옵션
--auto                        # 자동 선택
--detailed                    # 상세 정보
--history                     # 기록 보기
--export                      # 데이터 내보내기
```

최고의 AI 파트너를 찾아 생산성을 극대화하세요! 🚀