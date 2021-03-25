using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimatorPlay : MonoBehaviour
{
    // Start is called before the first frame update
    private Animator animator;
    public Animation animation;
    public string AnimationName;
    public bool rootAnim = false;
    public float offset = 0.0f;
    void Start()
    {
        animator = GetComponent<Animator>();
        animator.applyRootMotion = rootAnim;
        animator.Play(AnimationName,0,offset);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
