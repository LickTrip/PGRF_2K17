package grid;

import com.jogamp.opengl.GL2GL3;
import com.jogamp.opengl.GLAutoDrawable;
import com.jogamp.opengl.GLEventListener;

import oglutils.*;
import transforms.*;

import java.awt.event.*;

import static com.jogamp.opengl.GL.GL_UNPACK_ALIGNMENT;

/**
 * GLSL sample:<br/>
 * Read and compile shader from files "/shader/glsl01/start.*" using ShaderUtils
 * class in oglutils package (older GLSL syntax can be seen in
 * "/shader/glsl01/startForOlderGLSL")<br/>
 * Manage (create, bind, draw) vertex and index buffers using OGLBuffers class
 * in oglutils package<br/>
 * Requires JOGL 2.3.0 or newer
 *
 * @author PGRF FIM UHK
 * @version 2.0
 * @since 2015-09-05
 */
public class Renderer implements GLEventListener, MouseListener,
        MouseMotionListener, KeyListener {

    int width, height, axisX, axisY;

    OGLBuffers buffers;
    OGLTextRenderer textRenderer;

    int shaderProgram, locProj, locMV, locFunctionType, locEfectType,
            locDegreeOfEfect, locShowTexture, locNormalMapping, locRepeatTextW, locRepeatTextH, locChangeText;

    Camera camera = new Camera();
    Mat4 mProj = new Mat4Identity();

    OGLTexture2D texture1, texture1Norm, texture1Para, texture2, texture2Norm, texture2Para, texture2Ao;
    OGLTexture2D.Viewer textureViewer;

    double camSpeed = 0.35;
    float time = 0;
    //keys
    boolean line = false, textureSample = false, showTexture = true, normalMapping = true;

    int repeatTextW = 2, repeatTextH = 1;

    int degreeOfEfect = 0,
            basicTypeCount = 2, lightTypeCount = 4; /*textureTypeCount = 1*/
    ;

    int functionTypeCount = 6,
            functionType = 0;

    int efectTypeCount = 1,
            efectType = efectTypeCount;

    int changeText = 0;

    @Override
    public void init(GLAutoDrawable glDrawable) {
        // check whether shaders are supported
        GL2GL3 gl = glDrawable.getGL().getGL2GL3();
        OGLUtils.shaderCheck(gl);

        // get and set debug version of GL class
        gl = OGLUtils.getDebugGL(gl);
        glDrawable.setGL(gl);

        OGLUtils.printOGLparameters(gl);

        textRenderer = new OGLTextRenderer(gl, glDrawable.getSurfaceWidth(), glDrawable.getSurfaceHeight());
        //maping shaders//
        shaderProgram = ShaderUtils.loadProgram(gl, "/grid/start");
        //create buffer
        buffers = Factory.gridGenerate(gl, 160, 160);

        locMV = gl.glGetUniformLocation(shaderProgram, "mMV");
        locProj = gl.glGetUniformLocation(shaderProgram, "mProj");
        locFunctionType = gl.glGetUniformLocation(shaderProgram, "functionType");
        locEfectType = gl.glGetUniformLocation(shaderProgram, "efectType");
        locDegreeOfEfect = gl.glGetUniformLocation(shaderProgram, "degreeOfEfect");
        locShowTexture = gl.glGetUniformLocation(shaderProgram, "showTexture");
        locNormalMapping = gl.glGetUniformLocation(shaderProgram, "normalMap");
        locRepeatTextW = gl.glGetUniformLocation(shaderProgram, "repeatTextW");
        locRepeatTextH = gl.glGetUniformLocation(shaderProgram, "repeatTextH");
        locChangeText = gl.glGetUniformLocation(shaderProgram, "changeText");


        texture1 = new OGLTexture2D(gl, "/textures/bricks.jpg");
        texture1Norm = new OGLTexture2D(gl, "/textures/bricksn.png");
        texture1Para = new OGLTexture2D(gl, "/textures/bricksh.png");

        texture2 = new OGLTexture2D(gl, "/textures/eye_color.jpg");
        texture2Norm = new OGLTexture2D(gl, "/textures/eye_normal.png");
        texture2Para = new OGLTexture2D(gl, "/textures/eye_height.png");
        texture2Ao = new OGLTexture2D(gl, "/textures/eye_ao.png");
        //gl.glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        gl.glTexParameteri(GL2GL3.GL_TEXTURE_2D, GL2GL3.GL_TEXTURE_WRAP_S, GL2GL3.GL_REPEAT);
        gl.glTexParameteri(GL2GL3.GL_TEXTURE_2D, GL2GL3.GL_TEXTURE_WRAP_T, GL2GL3.GL_REPEAT);


        setMyCamera();

        gl.glEnable(GL2GL3.GL_DEPTH_TEST);
        textureViewer = new OGLTexture2D.Viewer(gl);
    }
    //TODO blending, paralax, normal + nrml, gloss, carpet
    private void setMyCamera() {
//        camera = camera.withPosition(new Vec3D(5, 5, 2.5))
//                .withAzimuth(Math.PI * 1.25)
//                .withZenith(Math.PI * -0.125);
        camera = camera.withPosition(new Vec3D(-3.5, 3.0, 2.0))
                .withAzimuth(-6.96)
                .withZenith(-0.45);
    }

    @Override
    public void display(GLAutoDrawable glDrawable) {
        GL2GL3 gl = glDrawable.getGL().getGL2GL3();

        gl.glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        gl.glClear(GL2GL3.GL_COLOR_BUFFER_BIT | GL2GL3.GL_DEPTH_BUFFER_BIT);

        // set the current shader to be used, could have been done only once (in
        // init) in this sample (only one shader used)
        gl.glUseProgram(shaderProgram);

        gl.glUniformMatrix4fv(locProj, 1, false, ToFloatArray.convert(mProj), 0);
        gl.glUniformMatrix4fv(locMV, 1, false, ToFloatArray.convert(camera.getViewMatrix()), 0);
        gl.glUniform1i(locFunctionType, functionType);
        gl.glUniform1i(locEfectType, efectType);
        gl.glUniform1i(locDegreeOfEfect, degreeOfEfect);
        gl.glUniform1i(locShowTexture, Factory.convertMyBool(showTexture));
        gl.glUniform1i(locNormalMapping, Factory.convertMyBool(normalMapping));
        gl.glUniform1i(locRepeatTextW, repeatTextW);
        gl.glUniform1i(locRepeatTextH, repeatTextH);
        gl.glUniform1i(locChangeText, changeText);


        texture1.bind(shaderProgram, "texture1", 0);
        texture1Norm.bind(shaderProgram, "texture1Norm", 1);
        texture1Para.bind(shaderProgram, "texture1Para", 2);
        texture2.bind(shaderProgram, "texture2", 3);
        texture2Norm.bind(shaderProgram, "texture2Norm", 4);
        texture2Para.bind(shaderProgram, "texture2Para", 5);
        texture2Ao.bind(shaderProgram, "texture2Ao", 6);
        if (line)
            gl.glPolygonMode(GL2GL3.GL_FRONT_AND_BACK, GL2GL3.GL_LINE);
        else
            gl.glPolygonMode(GL2GL3.GL_FRONT_AND_BACK, GL2GL3.GL_FILL);


        // bind and draw - prvni parametr - interpretace objektu, druha - shader program
        buffers.draw(GL2GL3.GL_TRIANGLES, shaderProgram);

        if (textureSample) {
            textureViewer.view(texture1, 0.5, 0.5, 0.5);
            textureViewer.view(texture1Norm, 0.5, 0.0, 0.5);
            textureViewer.view(texture1Para, 0.5, -0.5, 0.5);
        }


        //vrcholy u bean, slonní hlava, normála - upraveno, proc dela bordel pri oddaleni, nefunguje reflektor

        //pospisky
        String text = new String(this.getClass().getName());
        textRenderer.drawStr2D(3, height - 20, text);
        textRenderer.drawStr2D(width - 60,  height - 20, "Text-W: " + Integer.toString(repeatTextW));
        textRenderer.drawStr2D(width - 60, height - 40, "Text-H: " + Integer.toString(repeatTextH));
        textRenderer.drawStr2D(width - 40, 3, "Michal");
        textRenderer.drawStr2D(3, 54, "Texture: " + Boolean.toString(showTexture));
        textRenderer.drawStr2D(3, 37, "Type of function: " + Integer.toString(functionType));
        textRenderer.drawStr2D(3, 20, "Type of efect: " + Integer.toString(efectType));
        textRenderer.drawStr2D(8, 3, "Degreeof type efect: " + Integer.toString(degreeOfEfect));
    }

    @Override
    public void reshape(GLAutoDrawable drawable, int x, int y, int width,
                        int height) {
        this.width = width;
        this.height = height;
        mProj = new Mat4PerspRH(Math.PI / 4/*3*/, height / (double) width, 0.01, 1000.0);
        textRenderer.updateSize(width, height);
    }

    @Override
    public void mouseClicked(MouseEvent e) {
    }

    @Override
    public void mouseEntered(MouseEvent e) {
    }

    @Override
    public void mouseExited(MouseEvent e) {
    }

    @Override
    public void mousePressed(MouseEvent e) {
        axisX = e.getX();
        axisY = e.getY();
    }

    @Override
    public void mouseReleased(MouseEvent e) {
    }

    @Override
    public void mouseDragged(MouseEvent e) {
        camera = camera.addAzimuth((double) Math.PI * (axisX - e.getX()) / width)
                .addZenith((double) Math.PI * (e.getY() - axisY) / width);
        axisX = e.getX();
        axisY = e.getY();
    }

    @Override
    public void mouseMoved(MouseEvent e) {
    }

    @Override
    public void keyPressed(KeyEvent e) {
        switch (e.getKeyCode()) {
            case KeyEvent.VK_W:
                camera = camera.forward(camSpeed);
                break;
            case KeyEvent.VK_S:
                camera = camera.backward(camSpeed);
                break;
            case KeyEvent.VK_A:
                camera = camera.left(camSpeed);
                break;
            case KeyEvent.VK_D:
                camera = camera.right(camSpeed);
                break;
            case KeyEvent.VK_ALT:
                setMyCamera();
                break;
            case KeyEvent.VK_CONTROL:
                camera = camera.down(1);
                break;
            case KeyEvent.VK_SHIFT:
                camera = camera.up(1);
                break;
            case KeyEvent.VK_SPACE:
                camera = camera.withFirstPerson(!camera.getFirstPerson());
                break;
            case KeyEvent.VK_U:
                camera = camera.mulRadius(0.9f);
                break;
            case KeyEvent.VK_J:
                camera = camera.mulRadius(1.1f);
                break;
            case KeyEvent.VK_R:
                line = !line;
                break;
            case KeyEvent.VK_G:
                efectType++;
                degreeOfEfect = 0;
                if (efectType > efectTypeCount)
                    efectType = 0;
                break;
            case KeyEvent.VK_F:
                efectType--;
                degreeOfEfect = 0;
                if (efectType < 0)
                    efectType = efectTypeCount;
                break;
            case KeyEvent.VK_B:
                degreeOfEfect++;
                switch (efectType) {
                    case 0:
                        if (degreeOfEfect > basicTypeCount)
                            degreeOfEfect = 0;
                        break;
                    case 1:
                        if (degreeOfEfect > lightTypeCount)
                            degreeOfEfect = 0;
                        break;
                    /*case 2:
                        if (degreeOfEfect > textureTypeCount)
                            degreeOfEfect = 0;
                        break;*/
                }
                break;
            case KeyEvent.VK_V:
                degreeOfEfect--;
                switch (efectType) {
                    case 0:
                        if (degreeOfEfect < 0)
                            degreeOfEfect = basicTypeCount;
                        break;
                    case 1:
                        if (degreeOfEfect < 0)
                            degreeOfEfect = lightTypeCount;
                        break;
                    /*case 2:
                        if (degreeOfEfect < 0)
                            degreeOfEfect = textureTypeCount;
                        break;*/
                }
                break;
            case KeyEvent.VK_E:
                functionType++;
                degreeOfEfect = 0;
                if (functionType > functionTypeCount)
                    functionType = 0;
                break;
            case KeyEvent.VK_Q:
                functionType--;
                if (functionType < 0)
                    functionType = functionTypeCount;
                break;
            case KeyEvent.VK_C:
                textureSample = !textureSample;
                break;
            case KeyEvent.VK_T:
                showTexture = !showTexture;
                if (!showTexture)
                    textureSample = false;
                break;
            case KeyEvent.VK_P:
                normalMapping = !normalMapping;
                if (!normalMapping)
                    normalMapping = false;
                break;
            case KeyEvent.VK_NUMPAD4:
                if(repeatTextW > 1)
                    repeatTextW -= 1;
                break;
            case KeyEvent.VK_NUMPAD6:
                if(repeatTextW < 10)
                    repeatTextW += 1;
                break;
            case KeyEvent.VK_NUMPAD8:
                if(repeatTextH < 10)
                    repeatTextH += 1;
                break;
            case KeyEvent.VK_NUMPAD2:
                if(repeatTextH > 1)
                    repeatTextH -= 1;
                break;
            case KeyEvent.VK_NUMPAD5:
                repeatTextH = 1;
                repeatTextW = 1;
                break;
            case KeyEvent.VK_NUMPAD0:
                if (changeText == 0)
                    changeText = 1;
                else
                    changeText = 0;
                break;
            case KeyEvent.VK_ESCAPE:
                System.exit(0);
                break;
            //test
            case KeyEvent.VK_M:
                System.out.println(camera);
                break;
        }
    }

    @Override
    public void keyReleased(KeyEvent e) {
    }

    @Override
    public void keyTyped(KeyEvent e) {
    }

    @Override
    public void dispose(GLAutoDrawable glDrawable) {
//        GL2GL3 gl = glDrawable.getGL().getGL2GL3();
//        gl.glDeleteProgram(shaderProgram);

        glDrawable.getGL().getGL2GL3().glDeleteProgram(shaderProgram);
    }

}