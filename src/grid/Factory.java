package grid;

import com.jogamp.opengl.GL2GL3;
import oglutils.OGLBuffers;

import java.util.ArrayList;

public class Factory {

	public static OGLBuffers gridGenerate(GL2GL3 gl, int rows, int columns) {

		float[] vertexData = new float[rows * columns * 2];
		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < columns; j++) {
				// index do jednorozmerneho pole i jde p�es rows a j pres columns
				vertexData[(i * columns + j) * 2] = j / (float) (columns - 1);
				vertexData[(i * columns + j) * 2 + 1] = i / (float) (rows - 1);
			}
		}
		System.out.println(vertexData);

		OGLBuffers.Attrib[] attributes = { new OGLBuffers.Attrib("inPosition", 2) // 2 floats
				//new OGLBuffers.Attrib("inNormal", 3) // 3 floats
		};

		// trojuhelniky v index bufferu - mame pocet vrcholu
		int[] indexData = new int[(rows - 1) * (columns - 1) * 2 * 3];
		int myIndex = 0;
		for (int i = 0; i < rows - 1; i++) {
			for (int j = 0; j < columns - 1; j++) {
				indexData[myIndex] = j + i * columns;
				indexData[myIndex + 1] = (j + 1) + (i +1) * columns;
				indexData[myIndex + 2] = j + (i + 1) * columns;
				indexData[myIndex + 3] = j + i * columns;
				indexData[myIndex + 4] = (j + 1) + i  * columns;
				indexData[myIndex + 5] = (j + 1) + (i + 1) * columns;
				myIndex += 6;
			}
			
		}

		return new OGLBuffers(gl, vertexData, attributes, indexData);
	}

	public static OGLBuffers createBuffers(GL2GL3 gl) {
		float[] vertexBufferData = {
				-1, -1, 0.7f, 0, 0,
				1, 0, 0, 0.7f, 0,
				0, 1, 0, 0, 0.7f
		};
		int[] indexBufferData = {0, 1, 2};

		// vertex binding description, concise version
		OGLBuffers.Attrib[] attributes = {
				new OGLBuffers.Attrib("inPosition", 2), // 2 floats
				new OGLBuffers.Attrib("inColor", 3) // 3 floats
				//new OGLBuffers.Attrib("inTextureCoordinates", 2)
		};
		return new OGLBuffers(gl, vertexBufferData, attributes,
				indexBufferData);
		// the concise version requires attributes to be in this order within
		// vertex and to be exactly all floats within vertex

/*		full version for the case that some floats of the vertex are to be ignored
 * 		(in this case it is equivalent to the concise version):
 		OGLBuffers.Attrib[] attributes = {
				new OGLBuffers.Attrib("inPosition", 2, 0), // 2 floats, at 0 floats from vertex start
				new OGLBuffers.Attrib("inColor", 3, 2) }; // 3 floats, at 2 floats from vertex start
		buffers = new OGLBuffers(gl, vertexBufferData, 5, // 5 floats altogether in a vertex
				attributes, indexBufferData);
*/
	}

	public static int convertMyBool(boolean q){
		if (q)
			return 1;
		return 0;
	}
}
