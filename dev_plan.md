# Pulse 앱 개발 기획서

## 1. 앱 컨셉

### 핵심 가치
- **순간성**: 일시적으로 존재하는 콘텐츠를 통해 진정성 있는 소통 추구
- **진정성**: 필터링되지 않은 실제 감정과 생각을 공유하는 플랫폼
- **연결성**: 사용자 간 의미 있는 연결을 촉진하는 소셜 경험
- **간결함**: 직관적이고 단순한 UI/UX로 핵심 기능에 집중

### 비전 
Pulse는 소셜 미디어의 영구적 기록과 완벽함에 대한 압박에서 벗어나, 순간의 진실된 감정과 생각을 공유하는 플랫폼입니다. 사용자들은 24시간 동안만 존재하는 "펄스"를 통해 순간적이고 진정성 있는 소통을 경험합니다.

### 차별점
1. **일시성**: 모든 콘텐츠는 24시간 후 자동 삭제
2. **무필터 소통**: 과도한 편집 없이 실제 감정과 생각을 공유하는 문화
3. **미니멀 디자인**: 불필요한 기능을 제거하고 핵심 가치에 집중한 인터페이스
4. **실시간 소통**: 현재 일어나는 일과 감정에 초점을 맞춘 실시간 소통 강조

## 2. 개발 To-Do 리스트

### 1단계: 기본 기능 구현 (현재 진행 중)
- [x] Firebase 연동 (인증, Firestore, 스토리지)
- [x] 유저 인증 시스템 (이메일/비밀번호 로그인)
- [x] 구글 소셜 로그인 기능
- [x] 중앙 집중식 라우팅 시스템
- [x] 펄스(게시물) CRUD 기능
- [ ] 댓글 시스템 완성
- [ ] 사용자 프로필 관리
- [ ] 24시간 후 콘텐츠 자동 삭제 로직

### 2단계: 핵심 기능 강화
- [ ] 실시간 알림 시스템
- [ ] 사용자 팔로우/팔로잉 기능
- [ ] 이미지 업로드 및 표시 최적화
- [ ] 위치 기반 펄스 탐색
- [ ] 해시태그 시스템
- [ ] 오프라인 모드 지원 (로컬 캐싱)
- [ ] 앱 내 검색 기능 개선

### 3단계: 사용자 경험 향상
- [ ] 애니메이션 및 전환 효과 개선
- [ ] 다크 모드 지원
- [ ] 앱 성능 최적화 (로딩 시간, 메모리 사용)
- [ ] 접근성 기능 강화
- [ ] 다국어 지원
- [ ] 커스텀 테마 옵션

### 4단계: 안정성 및 확장성
- [ ] 자동화된 테스트 구현 (단위 테스트, 통합 테스트)
- [ ] 에러 로깅 및 분석 시스템
- [ ] 사용자 분석 및 행동 추적
- [ ] 앱 성능 모니터링
- [ ] 서버 부하 분산 전략
- [ ] 확장 가능한 백엔드 아키텍처

### 5단계: 고급 기능 (장기 계획)
- [ ] AI 기반 콘텐츠 추천
- [ ] 오디오/비디오 메시지 지원
- [ ] 라이브 스트리밍 기능
- [ ] 커뮤니티 큐레이션 시스템
- [ ] 익명 모드 및 프라이버시 강화 옵션
- [ ] 크로스 플랫폼 동기화 (웹 앱)

## 3. 기술 스택

### 프론트엔드
- **Flutter**: 크로스 플랫폼 UI 프레임워크
- **Dart**: 프로그래밍 언어
- **Provider/Riverpod**: 상태 관리 (추후 도입 예정)
- **GetX**: 라우팅 및 의존성 주입 (대안으로 고려)

### 백엔드
- **Firebase**:
  - Authentication: 사용자 인증
  - Firestore: NoSQL 데이터베이스
  - Storage: 미디어 파일 저장
  - Cloud Functions: 서버리스 기능 (24시간 삭제 등)
  - FCM: 푸시 알림

### DevOps
- **GitHub**: 버전 관리
- **Firebase App Distribution**: 테스트 배포
- **GitHub Actions**: CI/CD 파이프라인 (추후 도입)

## 4. 데이터 모델

### User
```
User {
  id: String
  email: String
  username: String
  profileImageUrl: String?
  bio: String?
  createdAt: Timestamp
  followersCount: int
  followingCount: int
}
```

### Pulse (게시물)
```
Pulse {
  id: String
  authorId: String
  content: String
  imageUrl: String?
  createdAt: Timestamp
  expiresAt: Timestamp
  likesCount: int
  commentsCount: int
  location: GeoPoint?
  hashtags: List<String>
}
```

### Comment
```
Comment {
  id: String
  pulseId: String
  authorId: String
  content: String
  createdAt: Timestamp
  likesCount: int
}
```

### Like
```
Like {
  id: String
  userId: String
  pulseId: String
  createdAt: Timestamp
}
```

### Follow
```
Follow {
  id: String
  followerId: String
  followingId: String
  createdAt: Timestamp
}
```

## 5. UI/UX 디자인 원칙

1. **미니멀리즘**: 불필요한 요소를 제거하고 핵심 기능에 집중
2. **직관성**: 사용자가 쉽게 이해하고 조작할 수 있는 인터페이스
3. **일관성**: 모든 화면에서 일관된 디자인 언어 사용
4. **피드백**: 사용자 행동에 즉각적인 시각적/촉각적 피드백 제공
5. **흐름**: 자연스러운 사용자 흐름을 고려한 화면 설계

## 6. 마케팅 전략 (초안)

1. **타겟 사용자**: Z세대 및 밀레니얼 세대 (18-35세)
2. **핵심 메시지**: "진짜 너를 보여줘" - 필터 없는 진정성 있는 소통
3. **채널 전략**:
   - 인스타그램, 틱톡 등 기존 SNS에서의 바이럴 마케팅
   - 인플루언서 협업
   - 대학 캠퍼스 이벤트
4. **출시 전략**: 초기 베타 테스트 그룹 구성 후 점진적 확장

## 7. 프로젝트 타임라인

### 2025년 5월 - 7월: 베타 개발 단계
- 기본 기능 완성 및 안정화
- 내부 테스트 및 디버깅
- UI/UX 개선

### 2025년 8월 - 9월: 클로즈드 베타
- 제한된 사용자 그룹에 베타 버전 배포
- 피드백 수집 및 반영
- 성능 최적화 및 안정성 개선

### 2025년 10월: 오픈 베타
- 더 넓은 사용자층에 공개
- 대규모 테스트 및 사용자 행동 분석
- 최종 버그 수정 및 기능 개선

### 2025년 12월: 정식 출시
- 앱스토어 및 구글 플레이스토어 정식 등록
- 마케팅 캠페인 시작
- 지속적인 업데이트 및 유지보수 계획 실행

## 8. 성공 지표

1. **사용자 참여도**:
   - DAU/MAU 비율 (목표: 40% 이상)
   - 세션 시간 및 빈도
   - 사용자당 일평균 펄스 생성 수

2. **성장 지표**:
   - 신규 사용자 획득률
   - 사용자 유지율 (1일, 7일, 30일)
   - 바이럴 계수 (추천을 통한 신규 사용자)

3. **기술적 지표**:
   - 앱 충돌률 (목표: 0.5% 미만)
   - 평균 로딩 시간
   - 서버 가용성

## 9. 리스크 관리

1. **기술적 리스크**:
   - Firebase 의존성에 따른 제한사항 관리
   - 실시간 데이터 동기화 성능 이슈 대응 계획
   - 스케일링 전략

2. **비즈니스 리스크**:
   - 사용자 확보 저조 시 대응 전략
   - 경쟁사 출현에 대한 대응 방안
   - 수익 모델 다각화 계획

3. **법적/윤리적 리스크**:
   - 개인정보 보호 및 데이터 보안 전략
   - 유해 콘텐츠 관리 정책
   - 지역별 규제 준수 계획

---

이 기획서는 프로젝트의 방향성을 제시하는 문서로, 개발 진행에 따라 유연하게 업데이트될 수 있습니다. 팀원들의 피드백과 사용자 테스트를 통해 지속적으로 개선해 나가겠습니다.
