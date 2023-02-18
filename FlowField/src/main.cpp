#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"
#include "cinder/gl/gl.h"
#include "cinder/Perlin.h"

using namespace ci;
using namespace ci::app;

#define PI 3.14159265358979323846

// Window dimensions in pixels
const int windowSizeX = 1920;
const int windowSizeY = 1080;
const int marginSize = 100;
const int gridResolution = 100;

// Arrow grid sizes
const float arrowLength = 15.0f;
const float headLength = 6.0f;
const float headRadius = 3.0f;

// Grid
const int nRows = (int)(windowSizeY + marginSize) / gridResolution;
const int nColumns = (int)(windowSizeX + marginSize) / gridResolution;
float **Grid;

// Points
const int nPoints = 5000;
int **Points;

// step length update
const float step_length = 10;

// Perlin noise generator
Perlin mPerlin = Perlin();

class FlowFieldApp : public App
{
public:
	void keyDown(KeyEvent event) override;

	void draw() override;
	void setup() override;
	void update() override;

	void initGrid();

	void initPoints();
	void simulatePoint(int *x, int *y);
};

void prepareSettings(FlowFieldApp::Settings *settings)
{

	settings->setMultiTouchEnabled(false);
	settings->setWindowSize(windowSizeX, windowSizeY);
}

void FlowFieldApp::initGrid()
{

	// std::cout << nRows << ", " << nColumns << "\n";
	Grid = new float *[nRows];
	for (int i = 0; i < nRows; i++)
	{
		Grid[i] = new float[nColumns];

		for (int j = 0; j < nColumns; j++)
		{

			Grid[i][j] = mPerlin.noise(((float)i) * 0.01f, ((float)j) * 0.01f) * PI * 2.0f;
		}
	}
}

void FlowFieldApp::initPoints()
{
	Points = new int *[nPoints];
	for (int i = 0; i < nPoints; i++)
	{
		Points[i] = new int[2];

		Points[i][0] = rand() % (windowSizeX + marginSize);
		Points[i][1] = rand() % (windowSizeY + marginSize);

		// std::cout << Points[i][0] << ", " << Points[i][1] << "\n";
	}
}

void FlowFieldApp::setup()
{
	initGrid();
	initPoints();
}

void FlowFieldApp::simulatePoint(int *x, int *y)
{

	int rowIndex = (int)*y / gridResolution;
	int columnIndex = (int)*x / gridResolution;

	rowIndex = std::min(rowIndex, nRows - 1);
	columnIndex = std::min(columnIndex, nColumns - 1);

	// std ::cout << rowIndex << ", " << columnIndex << "\n";

	float angle = Grid[rowIndex][columnIndex];

	float x_step = step_length * cos(angle);
	float y_step = step_length * sin(-angle);

	*x = (int)*x + x_step;
	*y = (int)*y + y_step;

	if (*x > windowSizeX+marginSize)
	{
		*x = 0;
	}

	if (*y > windowSizeY+marginSize)
	{
		*y = 0;
	}

	if (*x < 0)
	{
		*x = windowSizeX+marginSize;
	}

	if (*y < 0)
	{
		*y = windowSizeY+marginSize;
	}
}

void FlowFieldApp::update()
{
	for (int i = 0; i < nPoints; i++)
	{
		simulatePoint(&Points[i][0], &Points[i][1]);
	}
}

void FlowFieldApp::keyDown(KeyEvent event)
{
	if (event.getChar() == 'f')
	{
		setFullScreen(!isFullScreen());
	}
	else if (event.getCode() == KeyEvent::KEY_ESCAPE)
	{
		if (isFullScreen())
			setFullScreen(false);
		else
			quit();
	}
}

void FlowFieldApp::draw()
{
	gl::clear(Color::gray(0.1f));
	gl::color(1.0f, 1.0f, 1.0f);

	/*
	for (int i = 0; i < nRows; i++)
	{
		for (int j = 0; j < nColumns; j++)
		{
			float angle = Grid[i][j];

			float y = (i * gridResolution);
			float x = (j * gridResolution);

			// std :: cout << x << ", " << y << "\n";

			vec3 p1(x, y, 0.0f);
			vec3 p2(x + arrowLength * cos(angle), y + arrowLength * sin(-angle), 0.0f);

			gl::drawVector(p1, p2, headLength, headRadius);
		}
	}

	*/

	for (int i = 0; i < nPoints; i++)
	{

		vec2 p(Points[i][0]- (int)marginSize/2, Points[i][1]- (int)marginSize/2);
		gl::drawSolidCircle(p, 2);
	}

	gl::end();
}

CINDER_APP(FlowFieldApp, RendererGl, prepareSettings)