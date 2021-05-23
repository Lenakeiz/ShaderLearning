using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class AnimationController : MonoBehaviour
{
    // Start is called before the first frame update

    [SerializeField]
    public List<GameObject> lanterns;
    public Vector2 durationMovementRange = new Vector2(5.0f, 9.0f);
    public float burningTime = 5.0f;
    private bool isLastLantern = false;
    void Start()
    {
        lanterns = lanterns.OrderBy(i => Guid.NewGuid()).ToList();
        StartCoroutine(Animation());
    }

    IEnumerator Animation()
    {
        for (int i = 0; i < lanterns.Count; i++)
        {
            Vector3 finalPos = lanterns[i].transform.position;
            finalPos.y += 30.0f;
            iTween.MoveTo(lanterns[i],
                iTween.Hash(
                    "position", finalPos,
                    "time", UnityEngine.Random.Range(durationMovementRange.x, durationMovementRange.y),
                    "easetype", iTween.EaseType.easeOutQuad,
                    "oncompletetarget", this.gameObject,
                    "oncomplete", "MovementEnded",
                    "oncompleteparams", i)
                );
            yield return new WaitForSeconds(0.1f);
        }
    }

    public void MovementEnded(object mValue)
    {
        //int mValueInt = (int)mValue;
        Debug.Log("Completed " + mValue);
        if (!isLastLantern)
        {
            isLastLantern = true;
            StartCoroutine(ShaderAnimation(Convert.ToInt32(mValue)));
        }
        StartCoroutine(ActivateParticles(Convert.ToInt32(mValue)));


    }

    IEnumerator ShaderAnimation(int index)
    {
        Material mat = lanterns[index].GetComponent<Renderer>().sharedMaterial;

        float t = 0.0f;

        while (t < burningTime)
        {
            t += Time.deltaTime / burningTime;
            mat.SetFloat("_Height", Mathf.Lerp(23.0f,40.0f,t));
            yield return new WaitForEndOfFrame();
        }


    }

    IEnumerator ActivateParticles(int index)
    {
        while (!isLastLantern)
            yield return new WaitForEndOfFrame();
        ParticleSystem emitter = lanterns[index].GetComponentInChildren<ParticleSystem>();
        emitter.Play();
    }

}
