(
s.boot;
s.options.memSize = 8192 * 4;
)

(
// ----- SAMPLES -----
~nostalgia = Buffer.readChannel(s, "sf/nostalgia.mp3".resolveRelative, channels:[0]);
~infinite  = Buffer.readChannel(s, "sf/infinite_love.mp3".resolveRelative, channels:[0]);
~prayer = Buffer.read(s, "sf/prayer.wav".resolveRelative);
~kaneko_part = Buffer.readChannel(s, "sf/kaneko.mp3".resolveRelative, channels:[0], numFrames:1000000);

// ----- ENVELOPES -----

s.waitForBoot{


	// ----- SYNTH DEFS -----
	var fftsize=256;
	var a_bufsize = PartConv.calcBufSize(fftsize, ~prayer);
	var a_irspectrum = Buffer.alloc(s, a_bufsize, 1);

	var b_bufsize = PartConv.calcBufSize(fftsize, ~kaneko_part);
	var b_irspectrum = Buffer.alloc(s, b_bufsize, 1);

	var switch_to;
	var activator;

	~fade_env = Env.asr(5, 1, 5, 'linear');
	a_irspectrum.preparePartConv(~prayer, fftsize);
	b_irspectrum.preparePartConv(~kaneko_part, fftsize);


	SynthDef(\nost, { |out, gate=1|
		var sig, env;
		// sig = GrainBuf.ar(2, Dust.ar(ExpRand(60, 60, 5)), LFNoise1.kr(0.3!2).exprange(0.0002, 0.2), ~nostalgia, 1, 0.244495, 2, 0, -1, 512);
		sig = GrainBuf.ar(2, Impulse.ar(3), 2, ~nostalgia, 1, LFNoise0.kr(0.5).range(0, 1), 2, 0, -1, 512);
		env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
		Out.ar(out, sig * env * -20.dbamp);
	}).add;

	SynthDef(\infi, { |out, gate=1|

		var sig, env;
		sig = GrainBuf.ar(2, Dust.ar(8), 2, ~infinite, 1, LFNoise1.ar(0.5).range(0, 1), 2, 0, -1, 512);
		env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
		Out.ar(out, sig * env * -17.dbamp);
	}).add;

	// Prayer Partial Convolution
	SynthDef(\prayer, { |out, gate=1|
		// If the Buffer UGen channel mismatch: expected 1, yet buffer has 2 channels, is showing up, that's okay.
		// It sounds too obviously like the prayer sound file if I convert it to one channel. I'm not sure exactly what makes the difference, but there is one. And I like it. Sue me!!!
		var sig, env;
		sig = PartConv.ar(PlayBuf.ar(1, ~prayer, 1, loop:1)*0.0125, fftsize, a_irspectrum, 0.125);
		env = EnvGen.kr(~fade_env, gate, doneAction: Done.freeSelf);
		Out.ar(0, sig * env ! 2);
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


	~synths = Dictionary.new;

	~synths = ~synths.put(\M3, Dictionary.with(*["name"->\M3, "active"->false, "synth"->\prayer, "playing"->nil]));
	~synths = ~synths.put(\M2, Dictionary.with(*["name"->\M2, "active"->false, "synth"->\fm_exp, "playing"->nil]));
	~synths = ~synths.put(\M1, Dictionary.with(*["name"->\M1, "active"->false, "synth"->\fm_seq, "playing"->nil]));
	~synths = ~synths.put(\N1, Dictionary.with(*["name"->\N1, "active"->false, "synth"->\infi, "playing"->nil]));
	~synths = ~synths.put(\B1, Dictionary.with(*["name"->\B1, "active"->false, "synth"->\nost, "playing"->nil]));

	~current = \N1;


	// ----- MAIN -----


	switch_to = {
		arg to;
		"Switching to %".format(to).postln;

		if (~synths[~current].at("active") == true,
			{
				~synths[~current].at("playing").release;
				// "Releasing %".format(~synths[~current].at("name")).postln;
		}, {});

		~synths[~current].put("active", false);
		x = Synth(~synths[to].at("synth"));
		~synths[to].put("playing", x);
		~synths[to].put("active", true);
		~current = to;

	};

	switch_to.(\N1);

	activator = {
		arg msg, time, addr, recvPort;
		var next_state = msg[1];
		// "%".format(next_state).postln;

		if(~current != next_state,
			{
				switch_to.(next_state);
		}, {});

	};

	/*~most_recent = thisThread.seconds;
	~most_recent_down = thisThread.seconds;
	activator = {
		arg msg, time, addr, recvPort;
		var ax, ay, az, gx, gy, gz, sponge, switched, now, curr, onside, usd, shaken, notcool;
		switched = 0;
	/*	"Received packet:\n - msg: %\n - time: %\n - addr: %\n - recvPort: %"
    .format(msg, time, addr, recvPort)
    .postln;*/
		ax = msg[1]; ay = msg[2]; az = msg[3]; gx = msg[4]; gy = msg[5]; gz = msg[6];

		onside = (ay < 9.0) && (ay > -5);
		usd = (ay < -8);
		shaken = (gx.abs > 2.5) || (gy.abs > 2.5) || (gz.abs > 2.5);
		notcool = onside || usd || shaken;

		if ((~current == "B1"), {
		},{
		}

		now = thisThread.seconds;
		"%".format(now - ~most_recent).postln;
		if (now - ~most_recent > 10, {
			// ay should be greater than 9.5. If it isn't, move to an angrier state.
			if(onside,
				{
					~most_recent = now;
					curr = ~current;
					switch(curr,
						{"B1"}, {switch_to.("M1")},
						{"N1"}, {switch_to.("M1")},
						{"M1"}, {switch_to.("M2")},
						{"M2"}, {switch_to.("M3")},
						{"M3"}, {}
					);
			}, {
					// if ay < -8 immeadiately move to M3. It's upside down!!!
					if(usd,
						{
							~most_recent = now;
							curr = ~current;
							switch(curr,
								{"B1"}, {switch_to.("M3")},
								{"N1"}, {switch_to.("M3")},
								{"M1"}, {switch_to.("M3")},
								{"M2"}, {switch_to.("M3")},
								{"M3"}, {}
							);
					}, {
							// if any of the  gyros go greater than like 2, move to an angrier state.
							if(shaken,
								{
									~most_recent = now;
									curr = ~current;
									switch(curr,
										{"B1"}, {switch_to.("M1")},
										{"N1"}, {switch_to.("M1")},
										{"M1"}, {switch_to.("M2")},
										{"M2"}, {switch_to.("M3")},
										{"M3"}, {}
									);
								},{});
						}
					);
			});




		}, {});

		if (now - ~most_recent > 10, {
			// ay should be greater than 9.5. If it isn't, move to an angrier state.
			if(notcool, {},
				{
					~most_recent = now;
					curr = ~current;
					switch(curr,
						{"B1"}, {},
						{"N1"}, {
							if((sponge < 1000) && (sponge > 0),
								{
									switch_to.("B1");
								},
								{});
						},
						{"M1"}, {switch_to.("N1")},
						{"M2"}, {switch_to.("M1")},
						{"M3"}, {switch_to.("M2")}
					);
			});

			// if sponge is being touched and you're in normal state. If it is not too hard, move to blessing state. If it is too hard, move to really angry state.
		}, {});
	};*/

	~o = OSCFunc(activator, '/data');
}
)

{
    var x = 5;
    if (x == 5) {
        ^"Returning early because x is 5".postln;
    };
    "This will not be printed if x is 5".postln;
}.value;
