s.boot;

Server.killAll

(
// ----- SAMPLES -----
~nostalgia = Buffer.readChannel(s, "sf/nostalgia.mp3".resolveRelative, channels:[0]);
~infinite  = Buffer.readChannel(s, "sf/infinite_love.mp3".resolveRelative, channels:[0]);
~prayer = Buffer.read(s, "sf/prayer.wav".resolveRelative);
~kaneko = Buffer.readChannel(s, "sf/kaneko.mp3".resolveRelative, channels:[0]);
~kaneko_part = Buffer.readChannel(s, "sf/kaneko.mp3".resolveRelative, channels:[0], numFrames:1000000);

// ----- ENVELOPES -----
~fade_env = Env.asr(5, 1, 5, 'linear');
)


(
// ----- SYNTH DEFS -----
var fftsize=4096;
var a_bufsize = PartConv.calcBufSize(fftsize, ~prayer);
var a_irspectrum = Buffer.alloc(s, a_bufsize, 1);

var b_bufsize = PartConv.calcBufSize(fftsize, ~kaneko_part);
var b_irspectrum = Buffer.alloc(s, b_bufsize, 1);

var split_freq = 600;
a_irspectrum.preparePartConv(~prayer, fftsize);
b_irspectrum.preparePartConv(~kaneko_part, fftsize);


SynthDef(\nost, { |out, gate=1|
	var sig, env;
	// sig = GrainBuf.ar(2, Dust.ar(ExpRand(60, 60, 5)), LFNoise1.kr(0.3!2).exprange(0.0002, 0.2), ~nostalgia, 1, 0.244495, 2, 0, -1, 512);
	sig = GrainBuf.ar(2, Impulse.ar(3), 2, ~nostalgia, 1, LFNoise0.kr(0.5).range(0, 1), 2, 0, -1, 512);
	env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
	Out.ar(out, sig * env * -25.dbamp);
}).add;

SynthDef(\infi, { |out, gate=1|

	var sig, env;
	sig = GrainBuf.ar(2, Dust.ar(8), 2, ~infinite, 1, LFNoise1.ar(0.5).range(0, 1), 2, 0, -1, 512);
	env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
	Out.ar(out, sig * env * -20.dbamp);
}).add;

// Prayer Partial Convolution
SynthDef(\prayer, { |out, gate=1|
	// If the Buffer UGen channel mismatch: expected 1, yet buffer has 2 channels, is showing up, that's okay.
	// It sounds too obviously like the prayer sound file if I convert it to one channel. I'm not sure exactly what makes the difference, but there is one. And I like it. Sue me!!!
	var sig, env;
	sig = PartConv.ar(PlayBuf.ar(1, ~prayer, 1, loop:1)*0.0125, fftsize, a_irspectrum, 0.125);
	env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
	Out.ar(0, sig * env * -25.dbamp ! 2);
}).add;

// Boopy thing I did with Splay
SynthDef(\boopy, {|out, gate=1|
	var sig, env, freq, trig, seq;
	trig = Impulse.kr(SinOsc.kr(0.5, 0, 20, 20));
	seq = Drand([1, 2, 3, 4, 5], inf);
	freq = Demand.kr(trig, 0, seq);
	sig = SinOsc.ar(freq * 100);
	env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
	Out.ar(0, Splay.ar(sig * env, SinOsc.kr(0.5), center: SinOsc.kr(0.2)) * -43.dbamp);
}).add;

// FM Synths
SynthDef(\fm_seq, {|out=0, gate=1|
    var ctls = [
        // freq, phase, amp
        [Saw.kr(0.5).range(200, 310), 0, 1],
        [LFNoise1.kr(0.5).exprange(3, 310), 0, 1],
        [SinOsc.kr(20).exprange(0, 400), 0, 1],
        [LFNoise1.kr(20).exprange(3, 100), 0, 1],
        [LFNoise1.kr(0.5).exprange(3, 100), 0, 1],
        [LFNoise1.kr(0.5).exprange(3, 100), 0, 1]
    ];
	var algo = Demand.ar(Impulse.ar(8), 0, Dseq([1, 2, 3, 4, 5, 6, 7, 8, 9], inf));
	var env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
	Out.ar(0, Mix(FM7.arAlgo(8, ctls, SinOsc.ar(algo * 100))) * env ! 2 * -30.dbamp;)
}).add;

// FM with Convolution?
SynthDef(\fm_exp, {|out=0, gate=1|
    var ctls = [
        // freq, phase, amp
		[Saw.kr(300).exprange(50, 310), 0, 1],
        [LFNoise1.kr(0.5).exprange(50, 100), 0, 0.2],
		[Saw.kr(200).exprange(2, 400), 0, 0.2],
        [SinOsc.kr(400, add:200).exprange(3, 400), 0, 0.2],
        [SinOsc.kr(200, add:200).exprange(3, 400), 0, 0.2],
        [LFNoise1.kr(0.5).exprange(3, 400), 0, 0.2]
    ];
	var algo = Demand.kr(Impulse.kr(3), 0, Dseq([1, 2, 3, 4, 5, 6, 7, 8, 9], inf));
	var sig, env;
	sig = PartConv.ar(PlayBuf.ar(1, ~kaneko_part, 1, loop:1)*0.125, fftsize, b_irspectrum, 0.125);
	env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
	Out.ar(0, LPF.ar(sig * env * Mix(FM7.arAlgo(1, ctls, SinOsc.kr(100/algo))), 440) * -25.dbamp ! 2;)
}).add;
)

// A function that runs every 200 ms to check if the state is being changed.

~synths = Dictionary.new;

~synths = ~synths.put("M3", Dictionary.with(*["name"->"M3", "active"->false, "synth"->\prayer, "playing"->nil]));
~synths = ~synths.put("M2", Dictionary.with(*["name"->"M2", "active"->false, "synth"->\fm_exp, "playing"->nil]));
~synths = ~synths.put("M1", Dictionary.with(*["name"->"M1", "active"->false, "synth"->\fm_seq, "playing"->nil]));
~synths = ~synths.put("N1", Dictionary.with(*["name"->"N1", "active"->false, "synth"->\infi, "playing"->nil]));
~synths = ~synths.put("B1", Dictionary.with(*["name"->"B1", "active"->false, "synth"->\nost_high, "playing"->nil]));

~current = "N1";


// ----- MAIN -----
(

var switch_to;
switch_to {
	arg to;

	if (~synths[~current].at("active") == true,
		{
			~synths[~current].at("playing").release;
	}, {});

	~synths[~current].put("active", false);

	x = Synth(~synths[to].at("synth"));
	~synths[to].put("playing", x);
	~synths[to].put("active", true);
};

var activator;
activator = {
	arg ax, ay, az, gx, gy, gz, sponge, addr, recvPort;

	// ay should be greater than 9.5. If it isn't, move to an angrier state.
	// if any of the  gyros go greater than like 2, move to an angrier state.

	// if ay < -8 immeadiately move to M3.

	// set a timeout of like three seconds

	// if everything is cool, move down until you're in normal mode.

	// if sponge is being touched and you're in normal state. If it is not too hard, move to blessing state. If it is too hard, move to really angry state.

};

~o = OSCFunc(activator, '/data');
)

// Free OSC Func and location synths
(
~o.free;
~locations.do({arg loc; if(loc.at("active") == true, {loc.at("playing").release; loc.put("active", false);}, {})});
)



(
a = Synth(\prayer);
)

(
b = Synth(\fm_exp);
)
(
a = Synth(\fm_seq);
)

(
a = Synth(\infi);
)


(
a = Synth(\nost);
// b = Synth(\nost_low);
)
