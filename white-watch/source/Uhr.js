/*
CAUTION:
Be aware, this design is copy-right protected. Lincense fees might get legally enforced if comercially used:
https://en.wikipedia.org/wiki/Swiss_railway_clock

Recourses:
https://www.eguide.ch/en/objekt/sbb-bahnhofsuhr/
https://www.eguide.ch/wp-content/uploads/2261/1508_CHD151_foto_b.jpg
*/

const diameter = 400; //pixel

const a = diameter / 100;
const minW       = 1.4;    // multiple of a
const minH       = 3.5;    // multiple of a
const hourW      = 3.5;    // multiple of a
const hourH      = 12;     // multiple of a
const dialRadius = 48.5;   // multiple of a

const hourHandHa = 32;     // multiple of a
const hourHandHb = 12;     // multiple of a
const hourHandWa = 6.4;    // multiple of a
const hourHandWb = 5.2;    // multiple of a

const minuteHandHa = 46;   // multiple of a
const minuteHandHb = 12;   // multiple of a
const minuteHandWa = 5.2;  // multiple of a
const minuteHandWb = 3.6;  // multiple of a

const secondDiam   = 10.5; // multiple of a
const secondHandHa = 31.2; // multiple of a
const secondHandHb = 16.5; // multiple of a
const secondHandW  = 1.4;  // multiple of a

const easeMinute = "easeElasticOut";
const easeSecond = "easeLinear";

const secondDuration = 1000;
const minuteDuration = 300;

let secondDurationCur = 0;
let minuteDurationCur = 0;
let hourDurationCur   = 0;

let then = new Date();
let now = new Date();

let minutes = [];
let hour = [];
let minute = [];
let second = [];

const minAngle = 360 / 60;
for (let i = 0; i < 60; i++) {
    minutes.push({ angle: i * minAngle, isHour: i % 5 === 0 ? true : false });
}

let SVG = d3.select("body")
    .append("svg")
    .attr("width", diameter)
    .attr("height", diameter);

SVG.append("circle")
    .attr("class", "dial")
    .attr("r", diameter / 2)
    .attr("cx", diameter / 2)
    .attr("cy", diameter / 2);

SVG.append("circle")
    .attr("class", "centerPoint")
    .attr("r", 2*a)
    .attr("cx", diameter / 2)
    .attr("cy", diameter / 2);

SVG.append('g')
    .selectAll("rect")
    .data(minutes)
    .enter()
    .append('rect')
    .attr("class", "mark")
    .attr("x", function(d) {
        return diameter / 2 - (d.isHour ? hourW / 2 : minW / 2) * a
    })
    .attr("y", function(d) {
        return diameter / 2 - (d.isHour ? hourH : minH) * a
    })
    .attr("width", function(d) {
        return (d.isHour ? hourW : minW) * a
    })
    .attr("height", function(d) {
        return (d.isHour ? hourH : minH) * a
    })
    .attr("transform", function(d) {
        let transform = "rotate(" + d.angle + "," + diameter / 2 + "," + diameter / 2 + ")";
        transform += ",translate(0," + (-dialRadius + (d.isHour ? hourH : minH)) * a + ")";
        return transform;
    })

setTime();

let hourHand = createHand(hour, "hourHand",
    (diameter / 2 - hourHandWa / 2 * a) + "," + (diameter / 2 + hourHandHb * a) + " " +
    (diameter / 2 + hourHandWa / 2 * a) + "," + (diameter / 2 + hourHandHb * a) + " " +
    (diameter / 2 + hourHandWb / 2 * a) + "," + (diameter / 2 - hourHandHa * a) + " " +
    (diameter / 2 - hourHandWb / 2 * a) + "," + (diameter / 2 - hourHandHa * a)
);
let minuteHand = createHand(hour, "minuteHand",
    (diameter / 2 - minuteHandWa / 2 * a) + "," + (diameter / 2 + minuteHandHb * a) + " " +
    (diameter / 2 + minuteHandWa / 2 * a) + "," + (diameter / 2 + minuteHandHb * a) + " " +
    (diameter / 2 + minuteHandWb / 2 * a) + "," + (diameter / 2 - minuteHandHa * a) + " " +
    (diameter / 2 - minuteHandWb / 2 * a) + "," + (diameter / 2 - minuteHandHa * a)
);

SVG.selectAll("#secondHandContainer")
    .append('g')
    .data(second)
    .enter()
    .append('g')
    .attr("id", "secondHandContainer")
    .append('rect')
    .attr("class", "secondHand")
    .attr("x", diameter / 2 - secondHandW / 2 * a)
    .attr("y", diameter / 2 - (secondHandHa - secondDiam / 2 + 0.04) * a) // 0.04 for getting a nicer 
                                                                          // joint when using opacity
    .attr("width", secondHandW * a)
    .attr("height", (secondHandHa + secondHandHb - secondDiam) * a)

let secondHand = SVG.select("#secondHandContainer");

secondHand.append('circle')
    .attr("class", "secondHand")
    .attr("cx", diameter / 2)
    .attr("cy", diameter / 2 - secondHandHa * a)
    .attr("r", secondDiam * a / 2)

update();
setInterval(update, 1000);

function update() {
    setTime(now);

    // sometimes browser stop scripts when tab is in background
    // when the tab is focused again, the animation sucks when still the regular per
    // second times are in place
    
    let diff = now.getTime() - then.getTime();
    if (diff > 2000) {
      secondDurationCur = 0;
      minuteDurationCur = 0;
      hourDurationCur = 0;      
    }
  
    updateHand(hourHand, hour, hourDurationCur, "easeLinear");
    updateHand(minuteHand, minute, minuteDurationCur, easeMinute);
    updateHand(secondHand, second, secondDurationCur, easeSecond);

    secondDurationCur = secondDuration;
    minuteDurationCur = minuteDuration;
    hourDurationCur = 1000;
}

function createHand(data, className, points) {
    return SVG.append('g')
        .selectAll("polygon")
        .data(data)
        .enter()
        .append('polygon')
        .attr("class", className)
        .attr("points", points);
}

function updateHand(hand, data, duration, ease) {
    hand.data(data)
        .transition()
        .duration(duration)
        .ease(d3.[ease])
        .attr("transform", function(d) {
            return "rotate(" + d + "," + diameter / 2 + "," + diameter / 2 + ")";
        });
}

function setTime() {
    then = now;
    now = new Date();

    hour[0] = (now.getHours() < 12 ? now.getHours() : now.getHours() - 12) * 30 
              + (360 / 12) * (now.getMinutes() / 60) 
              + (360 / (12 * 60)) * (now.getSeconds() / 60);
    minute[0] = now.getMinutes() * 6;
    let secondsAngel = (now.getSeconds()+1) * 6.10169;
    second[0] = secondsAngel < 360 ? secondsAngel : 0;
}