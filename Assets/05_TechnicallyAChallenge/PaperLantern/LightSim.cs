using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightSim : MonoBehaviour
{
    private Light light;
    [SerializeField] private float minIntensity = 3.0f;
    [SerializeField] private float maxIntensity = 5.0f;
    [SerializeField] private float minWaitTime  = 0.2f;
    [SerializeField] private float maxWaitTime  = 0.5f;
    void Start()
    {
        light = GetComponent<Light>();
        StartCoroutine(SimulateLighting());
    }

    private IEnumerator SimulateLighting()
    {
        float intensity;
        float waitTime;

        while (true)
        {
            intensity = Random.Range(minIntensity, maxIntensity);
            waitTime = Random.Range(minWaitTime, maxWaitTime);

            light.intensity = intensity;

            yield return new WaitForSeconds(waitTime);
        }
    }
}
