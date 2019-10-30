﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class DarkRoomMusicController : MonoBehaviour
{
    public static DarkRoomMusicController instance;

    [SerializeField]
    private float volumeLerpSpeed = 3f;

    public enum Instrument
    {
        ArpBass,
        Toms
    }
    private const int InstrumentCount = 2;

    private AudioSource[] instrumentSources;
    private float[] volumeLevels;

    
	void Awake ()
    {
        instance = this;
        instrumentSources = Enumerable.Range(0, InstrumentCount)
            .Select(a => transform.Find(((Instrument)a).ToString())
                .GetComponent<AudioSource>())
            .ToArray();
        volumeLevels = instrumentSources.Select(a => 0f).ToArray();
    }

	void LateUpdate ()
    {
        for (int i = 0; i < instrumentSources.Length; i++)
        {
            var source = instrumentSources[i];
            source.volume = Mathf.MoveTowards(source.volume, volumeLevels[i], volumeLerpSpeed);
        }

        volumeLevels = volumeLevels.Select(a => 0f).ToArray();
	}

    public void SetVolumeLevel(Instrument instrument, float volume)
    {
        volumeLevels[(int)instrument] = Mathf.Max(volumeLevels[(int)instrument], volume);
    }
}
