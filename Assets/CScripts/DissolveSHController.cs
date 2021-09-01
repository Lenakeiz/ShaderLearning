using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DissolveSHController : MonoBehaviour
{

    SkinnedMeshRenderer rend;
    Material dissolveMat;
    //BotControlScript bcs;

    public float duration = 1.0f;
    public float delay = 0.5f;

    // Start is called before the first frame update
    void Start()
    {
        //bcs = GetComponent<BotControlScript>();
        //bcs.animChange += StartDissolving;

        rend = GetComponentInChildren<SkinnedMeshRenderer>();
        if(rend != null)
        {
            dissolveMat = rend.material;
        }
    }

    // Update is called once per frame
    void Update()
    {
        //if (Input.GetKeyDown(KeyCode.Space))
        //{
        //    StartDissolving();
        //}
    }

    private void StartDissolving()
    {
        StopAllCoroutines();
        StartCoroutine(Dissolve());
    }

    private IEnumerator Dissolve()
    {
        yield return new WaitForSeconds(delay);
        float c = 0.0f;

        while (c < 1.0f)
        {
            c += Time.deltaTime;
            
            dissolveMat.SetFloat("_Level", c/duration);
            yield return new WaitForEndOfFrame();
        }

    }

}
