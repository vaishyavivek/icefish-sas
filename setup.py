import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()
    setuptools.setup(
        name='Icefish SAS',
        version='1.4',
        scripts=['init'],
        author="Team Icefish",
        author_email="icefish@mail.com",
        description="Smart Attendance System from Team Icefish",
        long_description=long_description,
        long_description_content_type="text/markdown",
        url="https://bitbucket.org/vivekvaishya/icefish-sas/src",
        packages=setuptools.find_packages(),
        classifiers=[
            "Programming Language :: Python :: 3",
            "License :: OSI Approved :: GNU General Public License v3 or later (GPLv3+)",
            "Operating System :: OS Independent",
        ],
    )
