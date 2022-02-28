using System;

using UnityEngine;

namespace ColorWheel
{
    public class TextureProvider : MonoBehaviour
    {
        [SerializeField] private Texture[] textures;

        private int i;

        private void Start()
        {
            i = 0;
        }

        private void OnValidate()
        {
            const int MinLength = 1;
            if (textures is null || textures.Length < MinLength)
            {
                textures = new Texture[MinLength];
            }
        }

        public Texture GetNext()
        {
            Texture texture = textures[i];
            i = (i + 1) % textures.Length;
            return texture;
        }
    }
}
