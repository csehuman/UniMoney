# 유니머니 - 간편 가계부
> 개발 기간: 2022.10.06 ~ 2022.10.14

[![N|AppStore](https://camo.githubusercontent.com/256c4c0f137426227c87b21c9d7230e30362eba3d7bdd69cd212c343bb9a132c/68747470733a2f2f646576696d616765732d63646e2e6170706c652e636f6d2f6170702d73746f72652f6d61726b6574696e672f67756964656c696e65732f696d616765732f62616467652d646f776e6c6f61642d6f6e2d7468652d6170702d73746f72652e737667)](https://apps.apple.com/app/%EC%9C%A0%EB%8B%88%EB%A8%B8%EB%8B%88-%EA%B0%84%ED%8E%B8-%EA%B0%80%EA%B3%84%EB%B6%80/id6443841781)

## About
![N|Description](https://www.dropbox.com/s/45fo967cw47z06x/unimoney_screenshot.png?raw=1)

유니머니는 개인정보를 일절 수집하지 않는 편하고 깔끔한 가계부 앱입니다.  
유니머니는 가계부 기능 외의 기능을 지원하지 않고, 가계부 앱이 과하게 불편하고 무거워지는 것을 지양합니다.  

유니머니의 주요 기능🌟
- 가계부 기록 추가, 수정, 삭제 기능.
- 일별, 월별, 연별 가계부 기록 보기.
- 카테고리별, 결제수단별 필터링 보기 기능.
- 카테고리 개인화 기능.
- 일별, 월별, 연별 가계부 분석 기능.

## Dev Skills
유니머니는 다음과 같은 기술로 만들어진 서비스입니다:
- UIKit & Storyboard
- MVC Pattern
- CocoaPods

## Library
유니머니는 다음과 같은 라이브러리를 사용합니다:
- [Realm](https://github.com/realm/realm-swift) - NoSQL기반 간편 로컬 데이터베이스
- [Charts](https://github.com/danielgindi/Charts) - 분석용 그래프/차트를 그리기 위해 사용

## Limitations & To-do
유니머니는 "앱스토어에 앱 정식 출시 해보기"를 목표로 진행한 미니프로젝트입니다.

점차 아래의 부분들을 개선해나갈 예정입니다:
- 현재는 지출/수입, 결제수단 등의 고정 선택지들이 모두 String으로 관리되고 있습니다. 이를 모두 enum으로 교체하여 데이터 안정성을 보장하는 방향으로 개선해나갈 예정입니다.
- 현재는 앱의 모든 UI가 Storyboard + 코드로 구성되어 있습니다. 장기적으로는 관리가 용이한 SnapKit 라이브러리를 사용해 Code-Only UI를 구성할 예정입니다.
- 현재는 Charts 라이브러리를 통해 만든 분석 차트의 가독성과 가시성이 좋지 않습니다. 해당 라이브러리를 조금 더 공부하여 차트를 커스터마이징 하거나, 직접 차트를 구현해볼 예정입니다.
