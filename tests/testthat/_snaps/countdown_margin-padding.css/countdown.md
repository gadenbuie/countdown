# countdown css template

    .countdown {
      background: inherit;
      position: absolute;
      cursor: pointer;
      font-size: 3em;
      line-height: 1;
      border-color: #ddd;
      border-width: 3px;
      border-style: solid;
      border-radius: 15px;
      box-shadow: 0px 4px 10px 0px rgba(50, 50, 50, 0.4);
      -webkit-box-shadow: 0px 4px 10px 0px rgba(50, 50, 50, 0.4);
      margin: 0;
      padding: 12px;
      text-align: center;
      -webkit-user-select: none;
         -moz-user-select: none;
          -ms-user-select: none;
              user-select: none;
    }
    .countdown {
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .countdown .countdown-time {
      background: none;
      font-size: 100%;
      padding: 0;
    }
    .countdown-digits {
      color: inherit;
    }
    .countdown.running {
      border-color: #2A9B59FF;
      background-color: #43AC6A;
    }
    .countdown.running .countdown-digits {
      color: #002F14FF;
    }
    .countdown.finished {
      border-color: #DE3000FF;
      background-color: #F04124;
    }
    .countdown.finished .countdown-digits {
      color: #4A0900FF;
    }
    .countdown.running.warning {
      border-color: #CEAC04FF;
      background-color: #E6C229;
    }
    .countdown.running.warning .countdown-digits {
      color: #3A2F02FF;
    }
    
    .countdown.running.blink-colon .countdown-digits.colon {
      opacity: 0.1;
    }

