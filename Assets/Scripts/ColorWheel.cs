using UnityEngine;
using UnityEngine.UI;

namespace ColorWheel
{
    public class ColorWheel : MonoBehaviour
    {
        [SerializeField] private Shader shader;
        [SerializeField] private Image image;
        [SerializeField] private TextureProvider textures;

        private void Start()
        {
            image.material = new Material(shader);
            SetNextTexture();
            SetColoringMode(ColoringMode.Multiplication);
        }

        private void OnGUI()
        {
            Event @event = Event.current;
            if (@event.type != EventType.KeyDown)
            {
                return;
            }

            switch (@event.keyCode)
            {
                case KeyCode.N:
                    SetNextTexture();
                    break;
                case KeyCode.Alpha1:
                case KeyCode.Alpha2:
                case KeyCode.Alpha3:
                    SetColoringMode((ColoringMode)(@event.keyCode - KeyCode.Alpha1));
                    break;
            }
        }

        private void SetNextTexture()
        {
            var material = new Material(image.material);
            material.SetTexture("_MainTex", textures.GetNext());
            image.material = material;
        }

        private void SetColoringMode(ColoringMode mode)
        {
            var material = new Material(image.material);
            material.SetInt("_ColoringMode", (int)mode);
            image.material = material;
        }
    }
}
