// JimFS - C4 model
// Source of truth: google/jimfs @ 8fa098e0715aa492914285312c07e151d2aace4d (branch master)
// Every element/relationship below carries a "// evidence:" pointer verified on a shallow
// clone of that commit. Paths are repo-relative; main-package files live in
// jimfs/src/main/java/com/google/common/jimfs/ (one flat package, 62 files).

workspace "JimFS" "C4 model of google/jimfs - an in-memory implementation of the Java java.nio.file (NIO2) file system API, shipped as com.google.jimfs:jimfs." {

  model {

    // ================= L1: people and external systems =================

    // evidence: README.md:28-29 ("get a new FileSystem instance from the Jimfs class")
    dev = person "Java Developer" "Writes Java applications and tests that create and use JimFS in-memory file systems"

    // evidence: Jimfs.java:96 (public static FileSystem newFileSystem()); README.md:28-29
    app = softwareSystem "JVM Application" "Java application that reads and writes files through the java.nio.file API on a JimFS file system"

    // evidence: pom.xml:86-88 (description "Jimfs is an in-memory implementation of Java 7's java.nio.file abstract file system API."); README.md:3-5
    jimfs = softwareSystem "JimFS" "In-memory implementation of the java.nio.file (NIO2) file system API for Java 8+" {

      // ============ L2: containers (responsibility clusters of the single package com.google.common.jimfs) ============

      // evidence: Jimfs.java:79 (public final class Jimfs); Configuration.java:205 (forCurrentPlatform); JimfsFileSystems.java:61-68 (assembly factory)
      facade = container "Facade and Configuration" "Public static factory (Jimfs), immutable Configuration presets, and the internal assembly that wires a new file system" "Java package cluster (com.google.common.jimfs)" {

        // ================= L3 components: Facade and Configuration =================

        // evidence: Jimfs.java:39 (javadoc "Static factory methods for creating new Jimfs file systems."), :79 (class decl), :96 (newFileSystem())
        cJimfs = component "Jimfs" "Public static factory - the only entry point developers use to create JimFS file systems" "Java class"

        // evidence: Configuration.java:85/:133/:176/:205 (unix()/osX()/windows()/forCurrentPlatform()), :218 (builder(PathType))
        cConfig = component "Configuration" "Immutable configuration presets (unix, osX, windows, forCurrentPlatform) plus a mutable builder" "Java class"

        // evidence: JimfsFileSystems.java:61-68 (newFileSystem(provider, uri, config) creating PathService, FileSystemState, file store, default view), :81 (AttributeService), :83 (HeapDisk)
        cAssembly = component "JimfsFileSystems" "Internal assembly that creates and wires PathService, FileSystemState, HeapDisk, JimfsFileStore, AttributeService and the default FileSystemView" "Java class"
      }

      // evidence: FileSystemView.java:57-59 (javadoc "contains the implementation of most file system operations"), :67 (final class FileSystemView); JimfsFileSystem.java:169-177 (fields)
      engine = container "In-Memory File-System Engine" "File tree (Directory/RegularFile), HeapDisk-backed storage, JimfsFileStore, FileSystemView operations and the JimfsFileSystem lifecycle" "Java package cluster (com.google.common.jimfs)" {

        // evidence: JimfsFileSystem.java:169-177 (private final provider/uri/fileStore/pathService/defaultView)
        eFs = component "JimfsFileSystem" "java.nio.file.FileSystem implementation holding the provider, file store, path service and default view" "Java class"

        // evidence: FileSystemView.java:57-59 (javadoc), :67 (class decl), :69/:71 (JimfsFileStore store + Directory workingDirectory), :126 (newDirectoryStream), :182 (isSameFile)
        eView = component "FileSystemView" "Implements most file-system operations, resolving relative paths against the working directory" "Java class"

        // evidence: JimfsFileSystems.java:102-103 (new JimfsFileStore(new FileTree(roots), fileFactory, disk, attributeService, ...)), JimfsFileStore.java:53 (private final HeapDisk disk)
        eStore = component "JimfsFileStore and FileTree" "NIO2 FileStore over the in-memory file tree; owns the FileFactory and the AttributeService reference" "Java classes"

        // evidence: JimfsFileSystems.java:83 (HeapDisk disk = new HeapDisk(config)), JimfsFileStore.java:53 (private final HeapDisk disk)
        eDisk = component "HeapDisk" "Allocates the in-memory blocks backing regular file content" "Java class"

        // evidence: FileSystemView.java:71 (private final Directory workingDirectory), RegularFile.java:21-22 (in-package static imports)
        eFiles = component "Directory and RegularFile" "File-tree nodes: directories with entries and regular files with content blocks" "Java classes"

        // evidence: JimfsFileSystems.java:64-65 (new FileSystemState(config.fileTimeSource, removeFileSystemRunnable(uri))), FileSystemState.java:24 (errorprone import CanIgnoreReturnValue)
        eState = component "FileSystemState" "Tracks open channels and streams and runs close actions when a file system is removed" "Java class"
      }

      // evidence: PathService.java:33 (import com.google.common.jimfs.PathType.ParseResult), JimfsFileSystems.java:63 (new PathService(config)), PathNormalization.java:21/:71-72/:80
      paths = container "Path and Name Services" "Parsing and serializing jimfs:// paths for unix, osX and windows path types, plus name normalization"

      // evidence: AttributeService.java:47/:51-53 (provider maps), JimfsFileSystems.java:81 (new AttributeService(config)), AttributeService.java:133 (StandardAttributeProviders.get(view))
      attrs = container "Attribute and Security Services" "File-attribute views (basic/dos/unix/posix/acl/owner/user) and user and group lookup"

      // evidence: JimfsFileSystemProvider.java:61 (final class ... extends FileSystemProvider), SystemJimfsFileSystemProvider.java:62-63 (@AutoService(FileSystemProvider.class) extends FileSystemProvider), Handler.java:39 (extends URLStreamHandler), JimfsFileSystemProvider.java:156/:191/:202 (channels/streams)
      jdkio = container "JDK Integration Surfaces" "SPI providers registered with the JDK, channels and streams, jimfs:// URL support, and the watch service" "Java package cluster (com.google.common.jimfs)" {

        // evidence: SystemJimfsFileSystemProvider.java:62-63 (@AutoService(FileSystemProvider.class); final class ... extends FileSystemProvider), :55-59 (javadoc: public but not used directly)
        kSysProvider = component "SystemJimfsFileSystemProvider" "Public SPI provider registered with the JDK ServiceLoader; serves the already-created FileSystem instance" "Java class"

        // evidence: JimfsFileSystemProvider.java:61 (final class JimfsFileSystemProvider extends FileSystemProvider), :63/:75-76 (INSTANCE singleton + instance())
        kProvider = component "JimfsFileSystemProvider" "Internal provider singleton implementing the operations behind Files.* on a JimFS file system" "Java class"

        // evidence: JimfsFileSystemProvider.java:156 (new JimfsFileChannel(file, opts, view.state())), :191 (new JimfsInputStream), :202 (new JimfsOutputStream)
        kChan = component "Channels and Streams" "JimfsFileChannel, JimfsAsynchronousFileChannel and JimfsInputStream/JimfsOutputStream over in-memory files" "Java classes"

        // evidence: Handler.java:39 (public final class Handler extends URLStreamHandler), :79-80 (openConnection returns new PathURLConnection(url))
        kUrlHandler = component "Handler" "java.net.URLStreamHandler for the jimfs:// protocol" "Java class"

        // evidence: PathURLConnection.java:53 (final class PathURLConnection extends URLConnection), :20 (import static java.nio.charset.StandardCharsets.UTF_8)
        kUrlConn = component "PathURLConnection" "URLConnection exposing file content and attributes for jimfs:// URLs" "Java class"

        // evidence: AbstractWatchService.java:55 (abstract class AbstractWatchService implements WatchService), PollingWatchService.java:51 (final class PollingWatchService extends AbstractWatchService), WatchServiceConfiguration.java:67-68 (new PollingWatchService(view, pathService, view.state(), interval, timeUnit))
        kWatch = component "Watch Services" "AbstractWatchService and PollingWatchService implementing the JDK WatchService API" "Java classes"
      }
    }

    // evidence: SystemJimfsFileSystemProvider.java:63 (extends java.nio.file.FileSystemProvider); measured import counts: 188 plain + 23 static java.nio.file imports
    jdk = softwareSystem "JDK java.nio.file (NIO2)" "JDK NIO2 API and FileSystemProvider SPI that JimFS implements and plugs into"

    // evidence: jimfs/pom.xml:41-42 (dependency com.google.guava:guava); measured import counts: 176 cross-boundary Guava imports
    guava = softwareSystem "Guava" "Google core libraries used across the implementation"

    // evidence: PathNormalization.java:21 (import com.ibm.icu.lang.UCharacter), :71-72 (CASE_FOLD_UNICODE javadoc + enum constant), :80 (requires ICU4J guard)
    icu = softwareSystem "ICU4J (optional)" "Optional runtime dependency for Unicode case folding"

    // ================= L1 relationships =================

    // evidence: Jimfs.java:96 (public static FileSystem newFileSystem()); README.md:28-29
    dev -> jimfs "Creates in-memory file systems via Jimfs.newFileSystem(...)"
    // evidence: Jimfs.java:96 (returns java.nio.file.FileSystem); README.md:28-29
    app -> jimfs "Reads and writes files through the returned java.nio.file.FileSystem"
    // evidence: SystemJimfsFileSystemProvider.java:62 (@AutoService(FileSystemProvider.class) - ServiceLoader metadata generated at build)
    jdk -> jimfs "Discovers the system FileSystemProvider via ServiceLoader"
    // evidence: measured import counts (188 plain + 23 static java.nio.file imports); JimfsFileSystem.java:284 (returns JDK WatchService)
    jimfs -> jdk "Implements NIO2 API and SPI types (FileSystem, FileSystemProvider, WatchService, channels)"
    // evidence: jimfs/pom.xml:41-42; measured import counts (176 cross-boundary Guava imports)
    jimfs -> guava "Uses Guava base and collections"
    // evidence: PathNormalization.java:21/:71-72/:80
    jimfs -> icu "Optional Unicode case folding (CASE_FOLD_UNICODE)"

    // ================= L2 relationships =================

    // evidence: Jimfs.java:148 (JimfsFileSystems.newFileSystem(JimfsFileSystemProvider.instance(), uri, config))
    facade -> jdkio "Passes the JimfsFileSystemProvider singleton into the assembly"
    // evidence: JimfsFileSystems.java:63 (new PathService(config))
    facade -> paths "Assembly creates PathService from the Configuration"
    // evidence: JimfsFileSystems.java:67-68 (createFileStore + createDefaultView), :83 (HeapDisk), :102-103 (new JimfsFileStore(...)), :124 (new FileSystemView(...))
    facade -> engine "Assembly creates HeapDisk, JimfsFileStore and the default FileSystemView"
    // evidence: JimfsFileSystems.java:81 (new AttributeService(config))
    facade -> attrs "Assembly creates AttributeService from the Configuration"
    // evidence: JimfsFileSystemProvider.java:156 (view.state() inside newFileChannel), JimfsFileSystem.java:177 (private final FileSystemView defaultView)
    jdkio -> engine "Provider operations resolve files and channels through FileSystemView"
    // evidence: JimfsFileSystem.java:284-285 (newWatchService() -> watchServiceConfig.newWatchService(defaultView, pathService))
    engine -> jdkio "Creates the JDK WatchService via WatchServiceConfiguration"
    // evidence: JimfsFileSystems.java:107-108 (createDefaultView(config, JimfsFileStore, PathService)), JimfsFileSystem.java:173 (private final PathService pathService)
    engine -> paths "Operations are built on the shared PathService"
    // evidence: JimfsFileSystems.java:102-103 (new JimfsFileStore(..., attributeService, ...))
    engine -> attrs "JimfsFileStore applies attributes via AttributeService"
    // evidence: JimfsFileSystemProvider.java:61 (extends FileSystemProvider), Handler.java:39 (extends URLStreamHandler), PathURLConnection.java:53 (extends URLConnection)
    jdkio -> jdk "Extends FileSystemProvider, URLStreamHandler and URLConnection"

    // ================= L3 relationships: Facade and Configuration =================

    // evidence: Jimfs.java:114 (return newFileSystem(name, Configuration.forCurrentPlatform()))
    cJimfs -> cConfig "Defaults new file systems to Configuration.forCurrentPlatform()"
    // evidence: Jimfs.java:148
    cJimfs -> cAssembly "Delegates creation to JimfsFileSystems.newFileSystem(provider, uri, config)"

    // ================= L3 relationships: Engine =================

    // evidence: JimfsFileSystem.java:177 (private final FileSystemView defaultView)
    eFs -> eView "Delegates file-system operations to the default view"
    // evidence: JimfsFileSystem.java:172 (private final JimfsFileStore fileStore)
    eFs -> eStore "Exposes the file store for FileStore and attribute queries"
    // evidence: FileSystemView.java:69 (private final JimfsFileStore store)
    eView -> eStore "Resolves files through the store's file tree"
    // evidence: FileSystemView.java:71 (private final Directory workingDirectory)
    eView -> eFiles "Reads and writes directory entries and file content"
    // evidence: JimfsFileStore.java:53 (private final HeapDisk disk)
    eStore -> eDisk "Allocates blocks for regular file content"

    // ================= L3 relationships: JDK Integration Surfaces =================

    // evidence: JimfsFileSystemProvider.java:156/:191/:202 (new JimfsFileChannel / JimfsInputStream / JimfsOutputStream)
    kProvider -> kChan "Creates channels and streams for open files"
    // evidence: Handler.java:79-80 (openConnection returns new PathURLConnection(url))
    kUrlHandler -> kUrlConn "Opens a URLConnection for jimfs:// URLs"

  }

  views {

    systemContext jimfs "JimFS-L1" "System context: Java developers and JVM applications use JimFS, which plugs into the JDK NIO2 SPI and depends on Guava (ICU4J optional)." {
      include *
      autoLayout
    }

    container jimfs "JimFS-L2" "Containers: responsibility clusters inside the single package com.google.common.jimfs." {
      include *
      autoLayout
    }

    component facade "JimFS-L3-Facade" "Components of the Facade and Configuration container." {
      include *
      autoLayout
    }

    component engine "JimFS-L3-Engine" "Components of the In-Memory File-System Engine container." {
      include *
      autoLayout
    }

    component jdkio "JimFS-L3-Jdkio" "Components of the JDK Integration Surfaces container." {
      include *
      autoLayout
    }

  }

}
