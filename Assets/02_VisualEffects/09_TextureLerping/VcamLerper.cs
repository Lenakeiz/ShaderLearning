using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class VcamLerper : MonoBehaviour
{
    [SerializeField]
    CinemachineVirtualCamera mainC;
    [SerializeField]
    float pathPosition;
    [SerializeField]
    float totalTime;
    // Start is called before the first frame update
    void Start()
    {
        iTween.ValueTo(this.gameObject,
                iTween.Hash(
                    "from", 0.0f,
                    "to", 1.0f,
                    "time", totalTime,
                    "easetype", iTween.EaseType.linear,
                    "onupdate", "UpdatePathPosition")
                );
    }

    public void UpdatePathPosition(float f)
    {
        mainC.GetCinemachineComponent<CinemachineTrackedDolly>().m_PathPosition = f;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
