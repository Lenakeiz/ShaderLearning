using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class QuadRotationController : MonoBehaviour
{
    public bool animate;
    private bool isAnimating;

    public Material currMaterial;

    // Start is called before the first frame update
    void Start()
    {
        currMaterial = gameObject.GetComponent<Renderer>().sharedMaterial;

    }

    // Update is called once per frame
    void Update()
    {
        if (animate && !isAnimating)
        {
            isAnimating = true;
            StartCoroutine(ChangeCutout());
        }

        if (!animate)
        {
            isAnimating = false;
        }


    }

    private IEnumerator ChangeCutout()
    {
        while (isAnimating)
        {
            float start = 0f;
            float end = 0.4f;
            float interpolation = 0;
            float currValue = start;

            while (interpolation <= 1.0f)
            {
                interpolation += Time.deltaTime;
                currValue  = Mathf.Lerp(start, end, interpolation);
                currMaterial.SetFloat("_CutOut", currValue);
                yield return new WaitForEndOfFrame();
            }

            start = 0.4f;
            end = 0f;
            interpolation = 0;
            currValue = start;

            while (interpolation <= 1.0f)
            {
                interpolation += Time.deltaTime;
                currValue = Mathf.Lerp(start, end, interpolation);
                currMaterial.SetFloat("_CutOut", currValue);
                yield return new WaitForEndOfFrame();
            }

        }
    }
}
