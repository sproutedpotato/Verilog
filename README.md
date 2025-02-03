## Verilog

----------------

This is an alarm clock module created during the first semester of 24.
I am using 4 buttons, and I wrote it using verilog.

24년도 1학기, 디지털 시스템 설계 프로젝트에 작성하였습니다.
Verilog으로 작성한 알람시계 모듈 스크립트이며 4개의 버튼을 사용합니다.

----------------

moudle 1 : clockMain.v
> 모듈의 메인입니다. LED, 시간 표시, 시간 계산, 모드 변경 및 출력 등 여러가지 작업을 수행합니다.

module 2 : setAlarm.v
> 알람을 설정할 수 있도록 만든 모드입니다. 버튼을 눌렀을 때 지속적으로 숫자가 증가 또는 감소하여 알람 설정이 편하도록 작성하였습니다.

module 3 : setTime.v
> 현재 시간을 설정할 수 있도록 만든 모드입니다. 마찬가지로 지속적으로 숫자가 증감할 수 있도록 만들었습니다.

module 4 : setNumber.v
> clockMain에서 받은 시간을 분, 초 단위로 분리해줍니다.

module 5 : DECODER.v
> 받은 숫자를 segment로 바꾸는 모듈입니다.


