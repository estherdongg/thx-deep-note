(
{
    var numVoices = 30;

    // Generate initial and target frequencies
    var fundamentals = ({ rrand(200.0, 400.0) } ! numVoices).sort;
    var finalPitches = (numVoices.collect { |nv|
        if (((nv / (numVoices / 6)).floor == (nv / (numVoices / 6)).round),
            (nv / (numVoices / 6)).floor * 12,
            (nv / (numVoices / 6)).floor * 12 + 7
        )
    } + 28.5).midicps;

    // Envelopes
    var outerEnv = EnvGen.kr(Env([0.0, 0.1, 0.45, 1.01], [5, 9, 6], [0, 0]));
    var ampEnvelope = EnvGen.kr(Env([0, 1, 1, 0], [3, 25, 31], [2, 0, -4]), doneAction: 2);

    // Generate the sound using each voice
    var snd = Mix.fill(numVoices, { |numTone|
        var initRandomFreq = fundamentals[numTone] + LFNoise2.kr(0.5, -6.0);
        var destinationFreq = finalPitches[numTone] + LFNoise2.kr(0.05, numTone / 3);

        var sweepEnv = EnvGen.kr(
            Env([0.0, 0.001, 0.2, 1.0], [5, 8, 6], [-2.5, 0])
        );

        var freq = ((1 - sweepEnv) * initRandomFreq) + (sweepEnv * destinationFreq);

        Pan2.ar(
            BLowPass.ar(Saw.ar(freq), freq * 6, 0.6),
            rrand(-0.5, 0.5),
            (1 - (1 / (numTone + 0.5))) * 6 * 0.5
        ) / numVoices;
    });

    // Apply the Limiter to the final mixed signal and multiply by the ampEnvelope
    Limiter.ar(snd * ampEnvelope, 0.8);
}.play;
)
